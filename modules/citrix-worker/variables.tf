variable "name" {
    description = "Name der VM"
    type = string  
}

variable "resource_group_name" {
    description = "Name der Resource Group"
    type = string  
}

variable "location" {
    description = "Azure Region"
    type = string  
}

variable "subnet_id" {
  description = "ID des Subnets"
  type = string
}

variable "admin_password" {
  description = "Admin Passwort der VM"
  type = string
  sensitive = true
}

variable "size" {
  description = "VM Größe"
  type = string
  default = "Standard_D2s_v3"
}