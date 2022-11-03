variable "username" {
  description = "Username for Virtual Machines"
}

variable "password" {
  description = "Password for Virtual Machines"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_B1ls"
}

variable "shared-key" {
  description = "Shared key for network gateway connection"
}
