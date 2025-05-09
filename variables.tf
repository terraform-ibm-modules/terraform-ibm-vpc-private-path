########################################################################################################################
# Input Variables
########################################################################################################################
variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group where you want to create the service."
}

variable "tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the private path service."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the private path service created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

##############################################################################
# VPC Variables
##############################################################################

variable "subnet_id" {
  description = "ID of subnet."
  type        = string
}

##############################################################################
# NLB Variables
##############################################################################

variable "nlb_name" {
  type        = string
  description = "The name of the private path netwrok load balancer."
  default     = "pp-nlb"
}

variable "nlb_backend_pools" {
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
  description = "A list describing backend pools for the private path network load balancer."

  validation {
    condition = length(
      flatten(
        [
          for backend in var.nlb_backend_pools :
          true if contains(["tcp", "http"], backend.pool_health_type)
        ]
      )
    ) == length(flatten([for backend in var.nlb_backend_pools : true]))
    error_message = "Backend pool health type values can only be `tcp` or `http`."
  }

  validation {
    condition = length(
      flatten(
        [
          for backend in var.nlb_backend_pools :
          true if backend.pool_health_delay > backend.pool_health_timeout
        ]
      )
    ) == length(flatten([for backend in var.nlb_backend_pools : true]))
    error_message = "`pool_health_delay` must be greater than `pool_health_timeout` value."
  }

  validation {
    condition = length(
      flatten(
        [
          for backend in var.nlb_backend_pools :
          true if contains(["round_robin", "weighted_round_robin"], backend.pool_algorithm)
        ]
      )
    ) == length(flatten([for backend in var.nlb_backend_pools : true]))
    error_message = "Supported values are `round_robin` or `weighted_round_robin`."
  }

  validation {
    condition     = length(distinct([for backend in var.nlb_backend_pools : backend.listener_port])) == length([for backend in var.nlb_backend_pools : backend.listener_port])
    error_message = "`listener_port` for each backend pool should be unique number."
  }

  validation {
    condition     = length(distinct([for backend in var.nlb_backend_pools : backend.pool_name])) == length([for backend in var.nlb_backend_pools : backend.pool_name])
    error_message = "`pool_name` for each backend pool should be unique value."
  }

  validation {
    condition     = length([for backend in var.nlb_backend_pools : backend]) <= 10
    error_message = "You cannot define more than 10 backend pools."
  }
}

##############################################################################
# Private Path Variables
##############################################################################

variable "private_path_default_access_policy" {
  type        = string
  description = "The policy to use for bindings from accounts without an explicit account policy. The default policy is set to Review all requests. Supported options are `permit`, `deny`, or `review`."
  default     = "review"

  validation {
    condition     = contains(["review", "deny", "permit"], var.private_path_default_access_policy)
    error_message = "The specified access policy is not valid. Supported options are `permit`, `deny`, or `review`."
  }
}

variable "private_path_service_endpoints" {
  type        = list(string)
  description = "The list of name for the service endpoint where you want to connect your Private Path service. Enter a maximum number of 10 unique endpoint names for your service."
  validation {
    condition     = length(var.private_path_service_endpoints) < 11 && length(distinct(var.private_path_service_endpoints)) == length(var.private_path_service_endpoints) ? true : false
    error_message = "Enter a maximum number of 10 unique endpoint names for your service."
  }
}

variable "private_path_zonal_affinity" {
  type        = bool
  description = "When enabled, the endpoint service preferentially permits connection requests from endpoints in the same zone. Without zonal affinity, requests are distributed to all instances in any zone."
  default     = false
}

variable "private_path_name" {
  type        = string
  description = "The name of the Private Path service for VPC."
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
  description = "The account-specific connection request policies."
  default     = []
  validation {
    condition     = length([for policy in flatten(var.private_path_account_policies) : true if policy.access_policy == "review" || policy.access_policy == "deny" || policy.access_policy == "permit"]) == length(var.private_path_account_policies)
    error_message = "The specified access policy is not valid. Supported options are permit, deny, or review."
  }
}
