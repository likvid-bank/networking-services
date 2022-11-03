variable "tenant_id" {
  description = "Id of the Azure AD tenant that you want to offer your service in."
}

variable "subscription_id" {
  description = "Id of the Azure Subscription that should host the service broker container and state."
}

variable "scope" {
  description = "The scope on which the Service Principal will be granted permissions. Of the form `/providers/Microsoft.Management/managementGroups/<tenant_id>`"
}
