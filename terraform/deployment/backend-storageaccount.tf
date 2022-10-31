resource "azurerm_resource_group" "unipipe-networking" {
  name     = "unipipe-networking"
  location = "West Europe"
}

resource "azurerm_storage_account" "unipipe-networking" {
  name                     = "unipipenetworkinglikvid"
  resource_group_name      = azurerm_resource_group.unipipe-networking.name
  location                 = azurerm_resource_group.unipipe-networking.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "unipipe-networking" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.unipipe-networking.name
}
