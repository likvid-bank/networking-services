# networking-services

This repository is used as a backend for offering networking services to customers of the likvid bank cloud foundation.


## Repository structure

We use terraform for bootstrapping of the hub, service broker.
UniPipe terraform runner calls the module under `terraform/45eef657-0fd1-403f-975e-f133feb60489` whenever a new spoke is ordered.

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
    ├── deployment # module for deploying the service broker containers
    │   ├── env.sh
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
