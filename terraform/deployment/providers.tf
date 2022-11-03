terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.30.0"

    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.29.1"
    }
    github = {
      source  = "integrations/github"
      version = "~>5.7.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
  }
}

provider "azuread" {
  tenant_id = local.tenant_id
}

provider "azurerm" {
  tenant_id       = local.tenant_id
  subscription_id = local.subscription_id
  features {}
}

provider "github" {
  owner = "likvid-bank"
}
