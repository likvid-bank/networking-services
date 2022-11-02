terraform {
  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-networking"
  }
}

module "unipipe" {
   source = "git::https://github.com/meshcloud/terraform-azure-unipipe.git/?ref=f4786d1505b658aa12c0ff8ca7de770f47a8371c"

  subscription_id     = local.subscription_id
  resource_group_name = "unipipe-networking"

  unipipe_git_remote          = github_repository.instance_repository.ssh_clone_url
  unipipe_git_branch          = "main"
  unipipe_basic_auth_username = "marketplace"

  deploy_terraform_runner = true
  terraform_runner_environment_variables = {
    "TF_VAR_platform_secret" = azuread_service_principal_password.unipipe-networking.value
    "ARM_TENANT_ID"          = local.tenant_id
    "ARM_SUBSCRIPTION_ID"    = local.subscription_id
    "ARM_CLIENT_ID"          = azuread_application.unipipe-networking.application_id
    "ARM_CLIENT_SECRET"      = azuread_service_principal_password.unipipe-networking.value
  }
}

output "env_sh" {
  value = "Tipp: Source the file env.sh in this directory for local testing."
}

output "unipipe_basic_auth_username" {
  value = module.unipipe.unipipe_basic_auth_username
}

output "unipipe_basic_auth_password" {
  value     = module.unipipe.unipipe_basic_auth_password
  sensitive = true
}

output "url" {
  value = module.unipipe.url
}

# local file for testing
resource "local_file" "env_sh" {
  content  = <<EOT
#!/bin/bash
export TF_VAR_platform_secret="${azuread_service_principal_password.unipipe-networking.value}"
export ARM_TENANT_ID="${local.tenant_id}"
export ARM_SUBSCRIPTION_ID="${local.subscription_id}"
export ARM_CLIENT_ID="${azuread_application.unipipe-networking.application_id}"
export ARM_CLIENT_SECRET="${azuread_service_principal_password.unipipe-networking.value}"
EOT
  filename = "env.sh"
}
