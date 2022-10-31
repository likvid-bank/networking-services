provider "github" {
  owner = "likvid-bank"
}

resource "github_repository" "instance_repository" {
  name = "networking-services"

  visibility  = "private"
  description = "Instance repository for Networking Services in Likvid-Bank."
}


# The Service Broker accesses the repo via a deploy key
resource "github_repository_deploy_key" "unipipe_networking" {
  title      = "unipipe-service-broker-deploy-key"
  repository = github_repository.instance_repository.name
  key        = tls_private_key.git_ssh_key.public_key_openssh
  read_only  = "false"
}
