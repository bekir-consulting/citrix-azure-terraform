# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Hole aktuelle öffentliche IP automatisch
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westus2"

  tags = {
    Environment = "Terraform Getting Started"
    Team = "DevOps"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
}

#Subnet für Citrix Wokrer VMs
resource "azurerm_subnet" "citrix_Workers" {
  name = "subnet-citrix-workers"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

# Network Security Group für Citrix Provider
resource "azurerm_network_security_group" "citrix_nsg" {
  name = "nsg-citrix-workers"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # ICA Protokoll - Citrix Session Traffic
  security_rule {
    name = "Allow-ICA-TCP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "1494"
    source_address_prefix = "10.0.0.0/16"
    destination_address_prefix = "*"
}

  #CGP - Citrix Session Reliability
  security_rule {
    name = "Allow-CGP"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "2598"
    source_address_prefix = "10.0.0.0/16"
    destination_address_prefix = "*"

  }

  #RDP für Administration
  security_rule {
    name = "Allow-RDP-Internal"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  # WinRM für Ansible
  security_rule {
    name                       = "Allow-WinRM"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "${data.http.my_ip.response_body}/32"
    destination_address_prefix = "*"
  }

  #Alles andere blockieren
  security_rule {
    name = "Deny-All-Inbound"
    priority = 4096
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

#NSG mit Subnet verbinden
resource "azurerm_subnet_network_security_group_association" "citrix_nsg_assoc" {
  subnet_id = azurerm_subnet.citrix_Workers.id
  network_security_group_id = azurerm_network_security_group.citrix_nsg.id
}

module "citrix_worker_01" {
  source = "./modules/citrix-worker"
  name = "ctx-worker-01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  subnet_id = azurerm_subnet.citrix_Workers.id
  admin_password = var.admin_password
}