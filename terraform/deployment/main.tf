terraform {
  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-networking"
  }
}

locals {
  # The GitHub organization the instance repostiory lives in.
  github_owner = "likvid-bank"

  # Id of the Azure AD tenant that you want to offer your service in.
  tenant_id = "703c8d27-13e0-4836-8b2e-8390c588cf80" # devmeshcloud.onmicrosoft.com

  # Id of the Azure Subscription that should host the service broker container and state.
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services

  # The scope on which the Service Principal will be granted permissions.
  # Must be of the form `/providers/Microsoft.Management/managementGroups/<tenant_id>`
  scope = "/providers/Microsoft.Management/managementGroups/${local.tenant_id}"
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
