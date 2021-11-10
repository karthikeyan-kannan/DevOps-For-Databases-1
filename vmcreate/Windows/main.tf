provider "azurerm" {
features{}
}

resource "azurerm_resource_group" "rg" {
    name        = "${var.resource_prefix}-rg"
    location    = var.location
}

resource "azurerm_virtual_network" "vnet"{
    name                = "${var.resource_prefix}-vnet"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    address_space = ["10.0.0.0/16"]

}

resource "azurerm_network_security_group" "nsg" {
    name                = "${var.resource_prefix}-nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow_RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_subnet" "subnet" {
    name                    = "${var.resource_prefix}-subnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes        = ["10.0.0.0/24"] 

}
resource "azurerm_public_ip" "publicip" {
  name                = "${var.resource_prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "testvmforkarthik"
 
}

resource "azurerm_network_interface" "nic" {
    name                    = "${var.resource_prefix}-nic"
    resource_group_name     = azurerm_resource_group.rg.name
    location                = azurerm_resource_group.rg.location

    ip_configuration {
        name                            = "testconfig1"
        subnet_id                       = azurerm_subnet.subnet.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.publicip.id
    }

}
resource "azurerm_network_interface_security_group_association" "nsgassociation" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_windows_virtual_machine" "vm" {
    name                    = "${var.resource_prefix}"
    resource_group_name     = azurerm_resource_group.rg.name
    location                = azurerm_resource_group.rg.location
    network_interface_ids    = [azurerm_network_interface.nic.id]
    size                    = var.vm_size
    admin_username          = var.username
    admin_password          = var.password
    license_type            = "Windows_Server"

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
}