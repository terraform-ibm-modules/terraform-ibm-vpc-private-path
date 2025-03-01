# IBM Cloud VPC private path deployable architecture

This deployable architecture creates vpc private path in IBM Cloud and supports provisioning the following resources:

* A resource group, if one is not passed in.

![private-path-deployable-architecture](../../reference-architecture/deployable-architecture-private-path.svg)

**Important:** Because this solution contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments, do not call this solution from one or more other modules. For more information about how resources are associated with provider configurations with multiple modules, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
