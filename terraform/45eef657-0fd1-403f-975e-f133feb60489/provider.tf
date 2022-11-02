provider "azurerm" {
  alias           = "spoke-provider"
  subscription_id = var.tenant_id
  # client_id and client_secret must be set via env variables
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias           = "hub-provider"
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services
  # client_id and client_secret must be set via env variables
  features {}
}
