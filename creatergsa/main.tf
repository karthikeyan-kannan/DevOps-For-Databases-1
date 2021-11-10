provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "rg" {
  name     = "cloudskills-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "mySA" {
  name                     = "devopskarthik212"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = "true"

  tags = {
    environment = "staging"
  }
}