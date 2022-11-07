#
# storage for terraform state of service instances
#
resource "azurerm_storage_account" "unipipe_networking" {
  name                     = "unipipenetworkinglikvid"
  resource_group_name      = azurerm_resource_group.unipipe_networking.name
  location                 = azurerm_resource_group.unipipe_networking.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "unipipe_networking" {
  name                 = "tfstates"
  storage_account_name = azurerm_storage_account.unipipe_networking.name
}
#
# Service Principal for managing service instances
#
resource "azuread_application" "unipipe_networking" {
  display_name = "unipipe-networking"
}

resource "azuread_service_principal" "unipipe_networking" {
  application_id = azuread_application.unipipe_networking.application_id
}

resource "azuread_service_principal_password" "unipipe_networking" {
  service_principal_id = azuread_service_principal.unipipe_networking.object_id
}

#
# Permissions for the Service Principal to manage service instances
#
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
  principal_id       = azuread_service_principal.unipipe_networking.id
}

resource "azurerm_role_assignment" "networking_contributor" {
  scope                = local.scope
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.unipipe_networking.object_id
}

resource "azurerm_role_assignment" "unipipe_networking_backend" {
  scope                = azurerm_storage_account.unipipe_networking.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.unipipe_networking.id
}
