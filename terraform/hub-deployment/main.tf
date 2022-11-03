terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.29.1"
    }
  }

  backend "gcs" {
    bucket = "meshcloud-tf-states"
    prefix = "meshcloud-demo/unipipe-networking-hub"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  tenant_id       = "703c8d27-13e0-4836-8b2e-8390c588cf80" # meshcloud-dev
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services
}
