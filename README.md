# IBM Cloud Private Path module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-vpc-private-path?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-private-path/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

The Private Path solution solves security, privacy and complexity problems. Through Private Path, providers can deliver their services over the IBM Cloud private network backbone, ensuring secure and private interactions for consumers. Providers can offer their services to IBM Cloud customers over Private Path using the IBM Cloud infrastructure. Private Path components are used when connecting to IBM Cloud services, and can now be used for third-party applications and services. [Learn more](https://cloud.ibm.com/docs/private-path?topic=private-path-overview)


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-vpc-private-path](#terraform-ibm-vpc-private-path)
* [Examples](./examples)
    * [Advanced example](./examples/advanced)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-vpc-private-path

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

locals {
    region = "us-south"
}

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "private_path" {
  source                         = "terraform-ibm-modules/vpc-private-path/ibm"
  resource_group_id              = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
  subnet_id                      = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of subnet to use
  nlb_name                       = "nlb-name"
  private_path_name              = "private-path-name"
  private_path_service_endpoints = ["vpc-pps.example.com"]
}
```

### Required access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **VPC Infrastructure Services** service
        - `Editor` platform access


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.75.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_lb.ppnlb](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb) | resource |
| [ibm_is_lb_listener.listener](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_pool.pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool) | resource |
| [ibm_is_lb_pool_member.nlb_pool_members](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool_member) | resource |
| [ibm_is_private_path_service_gateway.private_path](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_private_path_service_gateway) | resource |
| [ibm_is_private_path_service_gateway_account_policy.private_path_account_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_private_path_service_gateway_account_policy) | resource |
| [ibm_is_private_path_service_gateway_operations.private_path_publish](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_private_path_service_gateway_operations) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the private path service created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details | `list(string)` | `[]` | no |
| <a name="input_nlb_listener_accept_proxy_protocol"></a> [nlb\_listener\_accept\_proxy\_protocol](#input\_nlb\_listener\_accept\_proxy\_protocol) | If set to true, listener forwards proxy protocol information that are supported by load balancers in the application family. Default value is false. | `bool` | `false` | no |
| <a name="input_nlb_listener_port"></a> [nlb\_listener\_port](#input\_nlb\_listener\_port) | The listener port for the private path netwrok load balancer. | `number` | `3120` | no |
| <a name="input_nlb_name"></a> [nlb\_name](#input\_nlb\_name) | The name of the private path netwrok load balancer. | `string` | `"pp-nlb"` | no |
| <a name="input_nlb_pool_algorithm"></a> [nlb\_pool\_algorithm](#input\_nlb\_pool\_algorithm) | The load-balancing algorithm for private path netwrok load balancer pool members. Supported values are `round_robin` or `weighted_round_robin`. | `string` | `"round_robin"` | no |
| <a name="input_nlb_pool_health_delay"></a> [nlb\_pool\_health\_delay](#input\_nlb\_pool\_health\_delay) | The interval between 2 consecutive health check attempts. The default is 5 seconds. Interval must be greater than `nlb_pool_health_timeout` value. | `number` | `5` | no |
| <a name="input_nlb_pool_health_monitor_port"></a> [nlb\_pool\_health\_monitor\_port](#input\_nlb\_pool\_health\_monitor\_port) | The port on which the load balancer sends health check requests. By default, health checks are sent on the same port where traffic is sent to the instance. | `number` | `null` | no |
| <a name="input_nlb_pool_health_monitor_url"></a> [nlb\_pool\_health\_monitor\_url](#input\_nlb\_pool\_health\_monitor\_url) | If you select HTTP as the health check protocol, this URL is used to send health check requests to the instances in the pool. By default, this is the root path `/` | `string` | `"/"` | no |
| <a name="input_nlb_pool_health_retries"></a> [nlb\_pool\_health\_retries](#input\_nlb\_pool\_health\_retries) | The maximum number of health check attempts made before an instance is declared unhealthy. The default is 2 failed health checks. | `number` | `2` | no |
| <a name="input_nlb_pool_health_timeout"></a> [nlb\_pool\_health\_timeout](#input\_nlb\_pool\_health\_timeout) | The maximum time the system waits for a response from a health check request. The default is 2 seconds. | `number` | `2` | no |
| <a name="input_nlb_pool_health_type"></a> [nlb\_pool\_health\_type](#input\_nlb\_pool\_health\_type) | The protocol used to send health check messages to instances in the pool. Supported values are `tcp` or `http`. | `string` | `"tcp"` | no |
| <a name="input_nlb_pool_member_instance_ids"></a> [nlb\_pool\_member\_instance\_ids](#input\_nlb\_pool\_member\_instance\_ids) | The list of instance ids that you want to attach to the back-end pool. | `list(string)` | `[]` | no |
| <a name="input_nlb_pool_member_port"></a> [nlb\_pool\_member\_port](#input\_nlb\_pool\_member\_port) | The port where traffic is sent to the instance. | `number` | `null` | no |
| <a name="input_private_path_account_policies"></a> [private\_path\_account\_policies](#input\_private\_path\_account\_policies) | The account-specific connection request policies. | <pre>list(object({<br/>    account       = string<br/>    access_policy = string<br/>  }))</pre> | `[]` | no |
| <a name="input_private_path_default_access_policy"></a> [private\_path\_default\_access\_policy](#input\_private\_path\_default\_access\_policy) | The policy to use for bindings from accounts without an explicit account policy. The default policy is set to Review all requests. Supported options are `permit`, `deny`, or `review`. | `string` | `"review"` | no |
| <a name="input_private_path_name"></a> [private\_path\_name](#input\_private\_path\_name) | The name of the Private Path service for VPC. | `string` | n/a | yes |
| <a name="input_private_path_publish"></a> [private\_path\_publish](#input\_private\_path\_publish) | Set this variable to `true` to allows any account to request access to to the Private Path service. If need be, you can also unpublish where access is restricted to the account that created the Private Path service by setting this variable to `false`. | `bool` | `false` | no |
| <a name="input_private_path_service_endpoints"></a> [private\_path\_service\_endpoints](#input\_private\_path\_service\_endpoints) | The list of name for the service endpoint where you want to connect your Private Path service. Enter a maximum number of 10 unique endpoint names for your service. | `list(string)` | n/a | yes |
| <a name="input_private_path_zonal_affinity"></a> [private\_path\_zonal\_affinity](#input\_private\_path\_zonal\_affinity) | When enabled, the endpoint service preferentially permits connection requests from endpoints in the same zone. Without zonal affinity, requests are distributed to all instances in any zone. | `bool` | `false` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group where you want to create the service. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of subnet. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional list of tags to be added to the private path service. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_policy_id"></a> [account\_policy\_id](#output\_account\_policy\_id) | The unique identifier of the PrivatePathServiceGatewayAccountPolicy. |
| <a name="output_lb_crn"></a> [lb\_crn](#output\_lb\_crn) | The CRN for this load balancer. |
| <a name="output_lb_id"></a> [lb\_id](#output\_lb\_id) | The unique identifier of the load balancer. |
| <a name="output_listener_id"></a> [listener\_id](#output\_listener\_id) | The unique identifier of the load balancer listener. |
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | The unique identifier of the load balancer pool. |
| <a name="output_pool_member_id"></a> [pool\_member\_id](#output\_pool\_member\_id) | The unique identifier of the load balancer pool member. |
| <a name="output_private_path_crn"></a> [private\_path\_crn](#output\_private\_path\_crn) | The CRN for this private path service gateway. |
| <a name="output_private_path_id"></a> [private\_path\_id](#output\_private\_path\_id) | The unique identifier of the PrivatePathServiceGateway. |
| <a name="output_private_path_vpc"></a> [private\_path\_vpc](#output\_private\_path\_vpc) | The VPC this private path service gateway resides in. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
