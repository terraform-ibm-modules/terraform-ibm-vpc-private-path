# Cloud automation for VPC Private Path

## Prerequisites
- An existing resource group

This solution supports provisioning and configuring the following infrastructure:
- A private path service.
- A private network load balancer.

![private-path-deployable-architecture](../../reference-architecture/deployable-architecture-private-path.svg)

**Important:** Because this solution contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments, do not call this solution from one or more other modules. For more information about how resources are associated with provider configurations with multiple modules, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.75.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_path"></a> [private\_path](#module\_private\_path) | ../.. | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.6 |

### Resources

| Name | Type |
|------|------|
| [ibm_is_vpc.vpc](https://registry.terraform.io/providers/ibm-cloud/ibm/1.75.0/docs/data-sources/is_vpc) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the private path service created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details | `list(string)` | `[]` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group in which to provision the private path services in. | `string` | `"Default"` | no |
| <a name="input_existing_subnet_id"></a> [existing\_subnet\_id](#input\_existing\_subnet\_id) | The ID of an existing subnet. | `string` | `null` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | The ID of an existing VPC. If the user provides only the `existing_vpc_id` the private path service will be provisioned in the first subnet. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The API key to use for IBM Cloud. | `string` | n/a | yes |
| <a name="input_network_loadbalancer_listener_accept_proxy_protocol"></a> [network\_loadbalancer\_listener\_accept\_proxy\_protocol](#input\_network\_loadbalancer\_listener\_accept\_proxy\_protocol) | If set to true, listener forwards proxy protocol information that are supported by load balancers in the application family. Default value is false. | `bool` | `false` | no |
| <a name="input_network_loadbalancer_listener_port"></a> [network\_loadbalancer\_listener\_port](#input\_network\_loadbalancer\_listener\_port) | The listener port for the private path netwrok load balancer. | `number` | `80` | no |
| <a name="input_network_loadbalancer_name"></a> [network\_loadbalancer\_name](#input\_network\_loadbalancer\_name) | The name of the private path netwrok load balancer. | `string` | `"pp-nlb"` | no |
| <a name="input_network_loadbalancer_pool_algorithm"></a> [network\_loadbalancer\_pool\_algorithm](#input\_network\_loadbalancer\_pool\_algorithm) | The load-balancing algorithm for private path netwrok load balancer pool members. Supported values are `round_robin` or `weighted_round_robin`. | `string` | `"round_robin"` | no |
| <a name="input_network_loadbalancer_pool_health_delay"></a> [network\_loadbalancer\_pool\_health\_delay](#input\_network\_loadbalancer\_pool\_health\_delay) | The interval between 2 consecutive health check attempts. The default is 5 seconds. Interval must be greater than `network_loadbalancer_pool_health_timeout` value. | `number` | `5` | no |
| <a name="input_network_loadbalancer_pool_health_monitor_port"></a> [network\_loadbalancer\_pool\_health\_monitor\_port](#input\_network\_loadbalancer\_pool\_health\_monitor\_port) | The port on which the load balancer sends health check requests. By default, health checks are sent on the same port where traffic is sent to the instance. | `number` | `80` | no |
| <a name="input_network_loadbalancer_pool_health_monitor_url"></a> [network\_loadbalancer\_pool\_health\_monitor\_url](#input\_network\_loadbalancer\_pool\_health\_monitor\_url) | If you select HTTP as the health check protocol, this URL is used to send health check requests to the instances in the pool. By default, this is the root path `/` | `string` | `"/"` | no |
| <a name="input_network_loadbalancer_pool_health_retries"></a> [network\_loadbalancer\_pool\_health\_retries](#input\_network\_loadbalancer\_pool\_health\_retries) | The maximum number of health check attempts made before an instance is declared unhealthy. The default is 2 failed health checks. | `number` | `2` | no |
| <a name="input_network_loadbalancer_pool_health_timeout"></a> [network\_loadbalancer\_pool\_health\_timeout](#input\_network\_loadbalancer\_pool\_health\_timeout) | The maximum time the system waits for a response from a health check request. The default is 2 seconds. | `number` | `2` | no |
| <a name="input_network_loadbalancer_pool_health_type"></a> [network\_loadbalancer\_pool\_health\_type](#input\_network\_loadbalancer\_pool\_health\_type) | The protocol used to send health check messages to instances in the pool. Supported values are `tcp` or `http`. | `string` | `"tcp"` | no |
| <a name="input_network_loadbalancer_pool_member_instance_ids"></a> [network\_loadbalancer\_pool\_member\_instance\_ids](#input\_network\_loadbalancer\_pool\_member\_instance\_ids) | The list of instance ids that you want to attach to the back-end pool. | `list(string)` | `[]` | no |
| <a name="input_network_loadbalancer_pool_member_port"></a> [network\_loadbalancer\_pool\_member\_port](#input\_network\_loadbalancer\_pool\_member\_port) | The port where traffic is sent to the instance. | `number` | `80` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To not use any prefix value, you can set this value to `null` or an empty string. | `string` | n/a | yes |
| <a name="input_private_path_account_policies"></a> [private\_path\_account\_policies](#input\_private\_path\_account\_policies) | The account-specific connection request policies. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-private-path/tree/main/solutions/standard/DA-types.md). | <pre>list(object({<br/>    account       = string<br/>    access_policy = string<br/>  }))</pre> | `[]` | no |
| <a name="input_private_path_default_access_policy"></a> [private\_path\_default\_access\_policy](#input\_private\_path\_default\_access\_policy) | The policy to use for bindings from accounts without an explicit account policy. The default policy is set to Review all requests. Supported options are `permit`, `deny`, or `review`. | `string` | `"review"` | no |
| <a name="input_private_path_name"></a> [private\_path\_name](#input\_private\_path\_name) | The name of the Private Path service for VPC. | `string` | `"private-path"` | no |
| <a name="input_private_path_publish"></a> [private\_path\_publish](#input\_private\_path\_publish) | Set this variable to `true` to allows any account to request access to to the Private Path service. If need be, you can also unpublish where access is restricted to the account that created the Private Path service by setting this variable to `false`. | `bool` | `false` | no |
| <a name="input_private_path_service_endpoints"></a> [private\_path\_service\_endpoints](#input\_private\_path\_service\_endpoints) | The list of name for the service endpoint where you want to connect your Private Path service. Enter a maximum number of 10 unique endpoint names for your service. | `list(string)` | n/a | yes |
| <a name="input_private_path_tags"></a> [private\_path\_tags](#input\_private\_path\_tags) | Optional list of tags to be added to the private path service. | `list(string)` | `[]` | no |
| <a name="input_private_path_zonal_affinity"></a> [private\_path\_zonal\_affinity](#input\_private\_path\_zonal\_affinity) | When enabled, the endpoint service preferentially permits connection requests from endpoints in the same zone. Without zonal affinity, requests are distributed to all instances in any zone. | `bool` | `false` | no |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the VPC resources are provisioned. | `string` | `"us-south"` | no |

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
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the Resource Group the instances are provisioned in. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group the instances are provisioned in. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
