# Public IP
resource "azurerm_public_ip" "pip" {
    name = "pip-${var.name}"
    location = var.location
    resource_group_name = var.resource_group_name
    allocation_method = "Static"
    sku = "Standard"
}

#Network Interface
resource "azurerm_network_interface" "nic" {
  name = "nic-${var.name}"
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
     name = "internal"
     subnet_id = var.subnet_id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id = azurerm_public_ip.pip.id
    }
}

# Windows VM
resource "azurerm_windows_virtual_machine" "vm" {
  name = var.name
  computer_name = substr(var.name, 0, 15)
  resource_group_name = var.resource_group_name
  location = var.location
  size = var.size
  admin_username = "citrixadmin"
  admin_password = var.admin_password

  network_interface_ids = [ 
    azurerm_network_interface.nic.id
   ]
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }
}

# WinRM automatisch aktivieren
resource "azurerm_virtual_machine_extension" "winrm_setup" {
  name                 = "winrm-setup"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -Command \"winrm quickconfig -force; Enable-PSRemoting -Force; netsh advfirewall firewall set rule name='Windows Remote Management (HTTP-In)' profile=Public new remoteip=any\""
  })
}