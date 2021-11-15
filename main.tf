terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "instagram" {
  name     = "inifsdfsiiddstagram"
  location = "northeurope"
}

resource "azurerm_virtual_network" "myvnet" {
  name = "my-vnet"
  address_space = ["10.0.0.0/16"]
  location = "northeurope"
  resource_group_name = azurerm_resource_group.instagram.name
}

resource "azurerm_subnet" "frontendsubnet" {
  name = "frontendSubnet"
  resource_group_name =  azurerm_resource_group.instagram.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_public_ip" "myvm1publicip" {
  name = "pip1"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.instagram.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "myvm1nic" {
  name = "myvm1-nic"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.instagram.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myvm1publicip.id
  }
}

resource "azurerm_windows_virtual_machine" "instagram_web" {
  name                  = "instagram_web"  
  location              = "northeurope"
  resource_group_name   = azurerm_resource_group.instagram.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "Password123!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
