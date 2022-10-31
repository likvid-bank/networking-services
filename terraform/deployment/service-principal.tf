terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.30.0"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.29.1"
    }
  }
}



locals {
  tenant_id       = "703c8d27-13e0-4836-8b2e-8390c588cf80" # devmeshcloud.onmicrosoft.com
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services

  scope = "/providers/Microsoft.Management/managementGroups/${local.tenant_id}"
}

provider "azuread" {
  tenant_id = local.tenant_id
}

provider "azurerm" {
  tenant_id       = local.tenant_id
  subscription_id = local.subscription_id
  features {}
}

resource "azuread_application" "unipipe-networking" {
  display_name = "unipipe-networking"
}

resource "azuread_service_principal" "unipipe-networking" {
  application_id = azuread_application.unipipe-networking.application_id
}

resource "azuread_service_principal_password" "unipipe-networking" {
  service_principal_id = azuread_service_principal.unipipe-networking.object_id
}

resource "azurerm_role_assignment" "networking_contributor" {
  scope                = local.scope
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.unipipe-networking.object_id
}

resource "azurerm_role_definition" "resource_group_contributor" {
  name        = "resource_group_contributor"
  scope       = local.scope
  description = "A custom role that allows to manage resource groups. Used by Cloud Foundation automation."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
    ]
  }

  assignable_scopes = [
    local.scope
  ]
}

resource "azurerm_role_assignment" "resource_group_contributor" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.resource_group_contributor.role_definition_resource_id
  principal_id       = azuread_service_principal.unipipe-networking.id
}

