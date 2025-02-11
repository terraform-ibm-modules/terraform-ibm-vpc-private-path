########################################################################################################################
# Input Variables
########################################################################################################################
variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group where you want to create the service."
}

variable "tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the Redis instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Redis instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
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

variable "nlb_listener_port" {
  type        = number
  description = "The listener port for the private path netwrok load balancer."
  default     = 3120
}

variable "nlb_listener_accept_proxy_protocol" {
  type        = bool
  description = "If set to true, listener forwards proxy protocol information that are supported by load balancers in the application family. Default value is false."
  default     = false
}

variable "nlb_pool_algorithm" {
  type        = string
  description = "The load-balancing algorithm for private path netwrok load balancer pool members. Supported values are `round_robin` or `weighted_round_robin`."
  default     = "round_robin"
  validation {
    condition     = contains(["round_robin", "weighted_round_robin"], var.nlb_pool_algorithm)
    error_message = "Supported values are `round_robin` or `weighted_round_robin`."
  }
}

variable "nlb_pool_health_delay" {
  type        = number
  description = "The interval between 2 consecutive health check attempts. The default is 5 seconds. Interval must be greater than `nlb_pool_health_timeout` value."
  default     = 5
  validation {
    condition     = var.nlb_pool_health_delay > var.nlb_pool_health_timeout
    error_message = "`nlb_pool_health_delay` must be greater than `nlb_pool_health_timeout` value."
  }
}

variable "nlb_pool_health_retries" {
  type        = number
  description = "The maximum number of health check attempts made before an instance is declared unhealthy. The default is 2 failed health checks."
  default     = 2
}

variable "nlb_pool_health_timeout" {
  type        = number
  description = "The maximum time the system waits for a response from a health check request. The default is 2 seconds."
  default     = 2
}

variable "nlb_pool_health_type" {
  type        = string
  description = "The protocol used to send health check messages to instances in the pool. Supported values are `tcp` or `http`."
  default     = "tcp"
  validation {
    condition     = contains(["tcp", "http"], var.nlb_pool_health_type)
    error_message = "Supported values are `tcp` or `http`."
  }
}

variable "nlb_pool_health_monitor_url" {
  type        = string
  description = "If you select HTTP as the health check protocol, this URL is used to send health check requests to the instances in the pool. By default, this is the root path `/`"
  default     = "/"
}

variable "nlb_pool_health_monitor_port" {
  type        = number
  description = "The port on which the load balancer sends health check requests. By default, health checks are sent on the same port where traffic is sent to the instance."
  default     = null
}

variable "nlb_pool_member_port" {
  type        = number
  description = "The port where traffic is sent to the instance."
  default     = null
  validation {
    condition     = length(var.nlb_pool_member_instance_ids) != 0 ? var.nlb_pool_member_port == null ? false : true : true
    error_message = "A value should be set for `nlb_pool_member_port` when you have instances attached to the backend pool."
  }
}

variable "nlb_pool_member_instance_ids" {
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
