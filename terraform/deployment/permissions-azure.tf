locals {
  tenant_id       = "703c8d27-13e0-4836-8b2e-8390c588cf80" # devmeshcloud.onmicrosoft.com
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services
}

locals {
  scope = "/providers/Microsoft.Management/managementGroups/${local.tenant_id}"
}

#
# Service Principal
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
# Permissions for the Service Principal
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

resource "azurerm_role_assignment" "unipipe_networking-backend" {
  scope                = azurerm_storage_account.unipipe_networking.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.unipipe_networking.id

}
