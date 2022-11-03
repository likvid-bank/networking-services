terraform {
  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-networking"
  }
}

resource "azurerm_resource_group" "unipipe_networking" {
  name     = "unipipe-networking"
  location = "West Europe"
}

module "unipipe" {
  source = "git::https://github.com/meshcloud/terraform-azure-unipipe.git/?ref=v0.2"

  resource_group_name = azurerm_resource_group.unipipe_networking.name

  unipipe_git_remote          = github_repository.instance_repository.ssh_clone_url
  unipipe_git_branch          = "main"
  unipipe_basic_auth_username = "marketplace"

  deploy_terraform_runner = true
  terraform_runner_environment_variables = {
    "TF_VAR_platform_secret" = azuread_service_principal_password.unipipe_networking.value
    "ARM_TENANT_ID"          = local.tenant_id
    "ARM_SUBSCRIPTION_ID"    = local.subscription_id
    "ARM_CLIENT_ID"          = azuread_application.unipipe_networking.application_id
    "ARM_CLIENT_SECRET"      = azuread_service_principal_password.unipipe_networking.value
  }

  depends_on = [
    azurerm_resource_group.unipipe_networking
  ]
}

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
