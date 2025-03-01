########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API key to use for IBM Cloud."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision the Databases for Elasicsearch in.  If a `prefix` input variable is specified, it is added to this name in the `<prefix>-value` format."
}

variable "region" {
  type        = string
  description = "The region in which the Event Notifications resources are provisioned."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to add to all resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."
  default     = "dev"
  validation {
    condition = (var.prefix == null ? true :
      alltrue([
        can(regex("^[a-z]{0,1}[-a-z0-9]{0,14}[a-z0-9]{0,1}$", var.prefix)),
        length(regexall("^.*--.*", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter, contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
  }
}

variable "private_path_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the private path service."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the private path service created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []
}

##############################################################################
# VPC Variables
##############################################################################

variable "existing_subnet_id" {
  description = "An existing subnet id."
  type        = string
}

##############################################################################
# NLB Variables
##############################################################################

variable "network_loadbalancer_name" {
  type        = string
  description = "The name of the private path netwrok load balancer."
  default     = "pp-nlb"
}

variable "network_loadbalancer_listener_port" {
  type        = number
  description = "The listener port for the private path netwrok load balancer."
  default     = 80
}

variable "network_loadbalancer_listener_accept_proxy_protocol" {
  type        = bool
  description = "If set to true, listener forwards proxy protocol information that are supported by load balancers in the application family. Default value is false."
  default     = false
}

variable "network_loadbalancer_pool_algorithm" {
  type        = string
  description = "The load-balancing algorithm for private path netwrok load balancer pool members. Supported values are `round_robin` or `weighted_round_robin`."
  default     = "round_robin"
}

variable "network_loadbalancer_pool_health_delay" {
  type        = number
  description = "The interval between 2 consecutive health check attempts. The default is 5 seconds. Interval must be greater than `network_loadbalancer_pool_health_timeout` value."
  default     = 5
}

variable "network_loadbalancer_pool_health_retries" {
  type        = number
  description = "The maximum number of health check attempts made before an instance is declared unhealthy. The default is 2 failed health checks."
  default     = 2
}

variable "network_loadbalancer_pool_health_timeout" {
  type        = number
  description = "The maximum time the system waits for a response from a health check request. The default is 2 seconds."
  default     = 2
}

variable "network_loadbalancer_pool_health_type" {
  type        = string
  description = "The protocol used to send health check messages to instances in the pool. Supported values are `tcp` or `http`."
  default     = "tcp"
}

variable "network_loadbalancer_pool_health_monitor_url" {
  type        = string
  description = "If you select HTTP as the health check protocol, this URL is used to send health check requests to the instances in the pool. By default, this is the root path `/`"
  default     = "/"
}

variable "network_loadbalancer_pool_health_monitor_port" {
  type        = number
  description = "The port on which the load balancer sends health check requests. By default, health checks are sent on the same port where traffic is sent to the instance."
  default     = null
}

variable "network_loadbalancer_pool_member_port" {
  type        = number
  description = "The port where traffic is sent to the instance."
  default     = null
}

variable "network_loadbalancer_pool_member_instance_ids" {
  type        = list(string)
  description = "The list of instance ids that you want to attach to the back-end pool."
  default     = []
}

##############################################################################
# Private Path Variables
##############################################################################

variable "private_path_default_access_policy" {
  type        = string
  description = "The policy to use for bindings from accounts without an explicit account policy. The default policy is set to Review all requests. Supported options are `permit`, `deny`, or `review`."
  default     = "review"
}

variable "private_path_service_endpoints" {
  type        = list(string)
  description = "The list of name for the service endpoint where you want to connect your Private Path service. Enter a maximum number of 10 unique endpoint names for your service."
}

variable "private_path_zonal_affinity" {
  type        = bool
  description = "When enabled, the endpoint service preferentially permits connection requests from endpoints in the same zone. Without zonal affinity, requests are distributed to all instances in any zone."
  default     = false
}

variable "private_path_name" {
  type        = string
  description = "The name of the Private Path service for VPC."
  default     = "private-path"
}

variable "private_path_publish" {
  type        = bool
  description = "Set this variable to `true` to allows any account to request access to to the Private Path service. If need be, you can also unpublish where access is restricted to the account that created the Private Path service by setting this variable to `false`."
  default     = false
}

variable "private_path_account_policies" {
  type = list(object({
    account       = string
    access_policy = string
  }))
  description = "The account-specific connection request policies. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-private-path/tree/main/solutions/standard/DA-types.md)."
  default     = []
}
