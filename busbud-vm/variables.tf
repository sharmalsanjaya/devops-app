variable "azure_region" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "busbud-rg"
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "busbud-vnet"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "busbud-subnet"
}

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
  default     = "busbud-nsg"
}

variable "vm_name" {
  description = "Virtual Machine name"
  type        = string
  default     = "busbud-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

