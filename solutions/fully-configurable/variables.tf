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

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group in which to provision the private path services in."
  default     = "Default"
}

variable "region" {
  type        = string
  description = "The region in which the VPC resources are provisioned."
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: `prod-0205-cos`."

  validation {
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }
  validation {
    # must not exceed 16 characters in length
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "private_path_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the private path service."
  default     = []
}

variable "private_path_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the private path service created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []
}

##############################################################################
# VPC Variables
##############################################################################

variable "existing_vpc_id" {
  description = "The ID of an existing VPC. If the user provides only the `existing_vpc_id` the private path service will be provisioned in the first subnet."
  type        = string
  default     = null
  validation {
    condition     = var.existing_vpc_id == null && var.existing_subnet_id == null ? false : true
    error_message = "A value for either `existing_vpc_id` or `existing_subnet_id` should be passed."
  }
}

variable "existing_subnet_id" {
  description = "The ID of an existing subnet."
  type        = string
  default     = null
}

##############################################################################
# NLB Variables
##############################################################################

variable "network_loadbalancer_name" {
  type        = string
  description = "The name of the private path netwrok load balancer."
  default     = "pp-nlb"
}

variable "network_loadbalancer_backend_pools" {
  type = list(object({
    pool_name                                = string
    pool_algorithm                           = optional(string, "round_robin")
    pool_health_delay                        = optional(number, 5)
    pool_health_retries                      = optional(number, 2)
    pool_health_timeout                      = optional(number, 2)
    pool_health_type                         = optional(string, "tcp")
    pool_health_monitor_url                  = optional(string, "/")
    pool_health_monitor_port                 = optional(number, 80)
    pool_member_port                         = optional(number)
    pool_member_instance_ids                 = optional(list(string), [])
    pool_member_application_load_balancer_id = optional(string)
    listener_port                            = optional(number)
    listener_accept_proxy_protocol           = optional(bool, false)
  }))
  default     = []
  description = "A list describing backend pools for the private path network load balancer. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-private-path/tree/main/solutions/fully-configurable/DA_inputs.md#options-with-backend-pools)."
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
  description = "The account-specific connection request policies. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-private-path/tree/main/solutions/fully-configurable/DA_inputs.md#options-with-acc-policies)."
  default     = []
}
