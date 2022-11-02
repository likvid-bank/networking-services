terraform {
  backend "azurerm" {
    # tenant, subscription, client id and secret must be set by env variables ARM_* because they were not picked up here
 
    resource_group_name  = "unipipe-networking"
    storage_account_name = "unipipenetworkinglikvid"
    container_name       = "tfstates"
    key                  = "service-binding-"
  }
}
