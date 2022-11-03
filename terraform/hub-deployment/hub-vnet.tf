locals {
  hub-location       = "westeurope"
  hub-resource-group = "hub-${local.hub-location}-vnet-rg"
  prefix-hub         = "hub-${local.hub-location}"
}

resource "azurerm_resource_group" "hub-vnet-rg" {
  name     = local.hub-resource-group
  location = local.hub-location
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${local.prefix-hub}-vnet"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.255.224/27"]
}

resource "azurerm_subnet" "hub-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.0.64/27"]
}

resource "azurerm_subnet" "hub-dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.0.32/27"]
}
