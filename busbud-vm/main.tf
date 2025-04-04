# Resource Group
resource "azurerm_resource_group" "busbud_rg" {
  name     = var.resource_group_name
  location = var.azure_region
}

# Virtual Network
resource "azurerm_virtual_network" "busbud_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.busbud_rg.location
  resource_group_name = azurerm_resource_group.busbud_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "busbud_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.busbud_rg.name
  virtual_network_name = azurerm_virtual_network.busbud_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "busbud_nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.busbud_rg.location
  resource_group_name = azurerm_resource_group.busbud_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "busbud_public_ip" {
  name                = "busbud-public-ip"
  location            = azurerm_resource_group.busbud_rg.location
  resource_group_name = azurerm_resource_group.busbud_rg.name
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "busbud_nic" {
  name                = "busbud-nic"
  location            = azurerm_resource_group.busbud_rg.location
  resource_group_name = azurerm_resource_group.busbud_rg.name

  ip_configuration {
    name                          = "busbud-nic-ipconfig"
    subnet_id                     = azurerm_subnet.busbud_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.busbud_public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "busbud_nsg_association" {
  network_interface_id      = azurerm_network_interface.busbud_nic.id
  network_security_group_id = azurerm_network_security_group.busbud_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "busbud_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.busbud_rg.name
  location            = azurerm_resource_group.busbud_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.busbud_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  #  Load script from external file
  custom_data = base64encode(file("./bootstrap.sh"))
}
