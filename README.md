# networking-services

This repository is used as a backend for offering networking services to customers of the likvid bank cloud foundation. The services are brokered by [unipipe service broker](https://github.com/meshcloud/unipipe-service-broker/).

## How-to

### Manually enter CIDR range for a newly created network service request

When a customer requests a new serivce instance, unipipe service broker commits an instance.yml file in the git repository under `instances/<uuid>/instance.yml`. The file contains the parameters provided by the customer. Check the value of `vnet_size`.

Example `instances/5a2a7ebf-b070-42c8-ae34-35e22e10f47e/instance.yml`:
```yml
---
serviceInstanceId: "5a2a7ebf-b070-42c8-ae34-35e22e10f47e"

...

parameters:
  vnet_size: "25"
  location: "WestEurope"
```

Create a file params.yml with a CIDR range that satisfies the customers ordered `vnet_size`.

Example `instances/5a2a7ebf-b070-42c8-ae34-35e22e10f47e/params.yml`:
```yml
address_space_workload: 10.50.1.0/25
```

unipipe will now create and apply the spoke and peerings for the customer.

### Work with the repository locally

Apply the terraform module inside `terraform/deployment/`.
This will create a file `terraform/deployment/env.sh` that contains the credentials of the service principal used in the automation container.
Run `source terraform/deployment/env.sh` to add the credentials to your env.
Run `unipipe terraform` or change into any instance directory and run `terraform apply`.


## Reference

### Repository structure

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

