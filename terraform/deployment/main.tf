terraform {
  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-networking"
  }
}

########## K8S
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gke_meshcloud-meshcloud--bc0_europe-west1-b_meshstacks"
}


resource "kubernetes_namespace" "unipipe_networking" {
  metadata {
    name = "unipipe-networking-likvid"
  }
}

locals {
  labels = {
    "app.kubernetes.io/name" = "unipipe-networking"
  }
}

resource "tls_private_key" "git_ssh_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "random_password" "basic_auth_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "unipipe_networking" {
  metadata {
    name      = "unipipe-networking-config"
    namespace = kubernetes_namespace.unipipe_networking.metadata[0].name
  }

  data = {
    "GIT_REMOTE"              = github_repository.instance_repository.ssh_clone_url
    "GIT_REMOTE_BRANCH"       = "main"
    "GIT_SSH_KEY"             = tls_private_key.git_ssh_key.private_key_pem
    "APP_BASIC_AUTH_USERNAME" = "marketplace"
    "APP_BASIC_AUTH_PASSWORD" = random_password.basic_auth_password.result

    # terraform-runner
    "GIT_USER_EMAIL"         = "terraform-runner@meshcloud.io"
    "GIT_USER_NAME"          = "terraform runner"
    "TF_VAR_platform_secret" = azuread_service_principal_password.unipipe-networking.value
    "ARM_TENANT_ID"          = local.tenant_id
    "ARM_SUBSCRIPTION_ID"    = local.subscription_id
    "ARM_CLIENT_ID"          = azuread_application.unipipe-networking.application_id
    "ARM_CLIENT_SECRET"      = azuread_service_principal_password.unipipe-networking.value
  }
}

resource "kubernetes_service" "meshfed" {
  metadata {
    name      = "unipipe-networking"
    namespace = kubernetes_namespace.unipipe_networking.metadata[0].name
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.labels

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "kubernetes_deployment" "unipipe_networking" {
  metadata {
    name      = "unipipe-networking"
    namespace = kubernetes_namespace.unipipe_networking.metadata[0].name
    labels    = local.labels
  }

  spec {
    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        name   = "unipipe-networking"
        labels = local.labels
      }

      spec {
        container {
          name  = "unipipe-service-broker"
          image = "ghcr.io/meshcloud/unipipe-service-broker:latest"

          port {
            name           = "http"
            container_port = 8075
          }

          env_from {
            secret_ref {
              name = "unipipe-networking-config"
            }
          }
        }

        container {
          name  = "unipipe-terraform-runner"
          image = "ghcr.io/meshcloud/unipipe-terraform-runner:latest"

          env_from {
            secret_ref {
              name = "unipipe-networking-config"
            }
          }
        }

      }
    }
  }
}
##### AZURE
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

output "env_sh" {
  value = "Tipp: Source the file env.sh in this directory for local testing."
}

output "url" {
  value = "http://unipipe-networking.${kubernetes_namespace.unipipe_networking.metadata[0].name}.svc.cluster.local"
}

output "password" {
  value     = random_password.basic_auth_password.result
  sensitive = true
}



output "unipipe_basic_auth_username" {
  value = module.unipipe.unipipe_basic_auth_username
}

output "unipipe_basic_auth_password" {
  value     = module.unipipe.unipipe_basic_auth_password
  sensitive = true
}

output "broker-url" {
  value = module.unipipe.url
}
