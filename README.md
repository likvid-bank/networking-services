# networking-services

This repository is used as a backend for offering networking services to customers of the likvid bank cloud foundation. The services are brokered by [unipipe service broker](https://github.com/meshcloud/unipipe-service-broker/).


## Repository structure

We use terraform for bootstrapping of the hub and service broker.
[UniPipe terraform runner](https://github.com/meshcloud/unipipe-service-broker/tree/master/terraform-runner) calls the module under `terraform/45eef657-0fd1-403f-975e-f133feb60489` whenever a new spoke is ordered.

```
.
├── README.md
├── catalog.yml
├── instances
│   ├── <uuid>
│   │   ├── bindings
│   │   │   └── <uuid>
│   │   │       ├── backend.tf
│   │   │       ├── binding.yml
│   │   │       ├── module.tf.json
│   │   │       └── status.yml
└── terraform
    ├── 45eef657-0fd1-403f-975e-f133feb60489 # module for creating a new spoke
    │   ├── backend.tf
    │   ├── main.tf
    │   ├── provider.tf
    │   └── variables.tf
    ├── deployment # module for deploying the service broker on Azure
    │   ├── main.tf
    │   ├── output.tf
    │   ├── permissions-azure.tf
    │   ├── permissions-git.tf
    │   └── providers.tf
    └── hub-deployment # module for deploying the hub in likvid's Azure environment
        ├── hub-nva.tf
        ├── hub-vm.tf
        ├── hub-vnet.tf
        ├── main.tf
        └── variables.tf
```

## Working with the repository locally

Apply the terraform module inside `terraform/deployment/`.
This will create a file `terraform/deployment/env.sh` that contains the credentials of the service principal used in the automation container.
Run `source terraform/deployment/env.sh` to add the credentials to your env.
Run `unipipe terraform` or change into any instance directory and run `terraform apply`.
