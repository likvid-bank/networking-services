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

output "env_sh" {
  value = "Tipp: Source the file env.sh in this directory for local testing."
}

# local file for testing
resource "local_file" "env_sh" {
  content  = <<EOT
#!/bin/bash
export TF_VAR_platform_secret="${azuread_service_principal_password.unipipe_networking.value}"
export ARM_TENANT_ID="${local.tenant_id}"
export ARM_SUBSCRIPTION_ID="${local.subscription_id}"
export ARM_CLIENT_ID="${azuread_application.unipipe_networking.application_id}"
export ARM_CLIENT_SECRET="${azuread_service_principal_password.unipipe_networking.value}"
EOT
  filename = "env.sh"
}
