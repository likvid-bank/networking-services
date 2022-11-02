#
# customers provide these variables when ordering the service
#
variable "location" {
  description = "Location of the network"
  type        = string
}

variable "vnet_size" {
  description = "Size of the requested vNet"
  type        = string
}

#
# service owners provide these variables manually after a service was requested
#
variable "address_space_workload" {
  description = "The address space in CIDR notation for your workload subnets."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.address_space_workload))
    error_message = "address_space_workload must be a valid CIDR range"
  }
}

#
# the marketplace provides these variables when the service is created
#
variable "tenant_id" {
  description = "Subscription ID of the subscription the network shall be created in."
  type        = string
}

variable "platform" {
  description = "Platform identifier the tenant belongs to."
  type        = string
}

variable "project_id" {
  description = "Identifier of the meshProject the service instance is provisioned in."
  type        = string
}

variable "customer_id" {
  description = "Identifier of the meshCustomer the service instance is provisioned in."
  type        = string
}

variable "plan_id" {
  description = "Id of the service plan used for the instance."
  type        = string
}

variable "plan_name" {
  description = "Name of the service plan used for the instance."
  type        = string
}

#
# This variable must be set as an environment variable.
#
variable "platform_secret" {
  description = "Client Secret of the Azure App Registration."
  type        = string
}
