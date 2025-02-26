#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.use_existing_resource_group == false ? (var.prefix != null ? "${var.prefix}-${var.resource_group_name}" : var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

locals {
  prefix                    = (var.prefix != null && trimspace(var.prefix) != "" ? "${var.prefix}-" : "")
  network_loadbalancer_name = "${local.prefix}${var.network_loadbalancer_name}"
  private_path_name         = "${local.prefix}${var.private_path_name}"
}

module "private_path" {
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  subnet_id                          = var.existing_subnet_id
  tags                               = var.private_path_tags
  access_tags                        = var.access_tags
  nlb_name                           = local.network_loadbalancer_name
  nlb_listener_port                  = var.network_loadbalancer_listener_port
  nlb_listener_accept_proxy_protocol = var.network_loadbalancer_listener_accept_proxy_protocol
  nlb_pool_algorithm                 = var.network_loadbalancer_pool_algorithm
  nlb_pool_health_delay              = var.network_loadbalancer_pool_health_delay
  nlb_pool_health_retries            = var.network_loadbalancer_pool_health_retries
  nlb_pool_health_timeout            = var.network_loadbalancer_pool_health_timeout
  nlb_pool_health_type               = var.network_loadbalancer_pool_health_type
  nlb_pool_health_monitor_url        = var.network_loadbalancer_pool_health_monitor_url
  nlb_pool_health_monitor_port       = var.network_loadbalancer_pool_health_monitor_port
  nlb_pool_member_port               = var.network_loadbalancer_pool_member_port
  nlb_pool_member_instance_ids       = var.network_loadbalancer_pool_member_instance_ids

  private_path_name                  = local.private_path_name
  private_path_default_access_policy = var.private_path_default_access_policy
  private_path_service_endpoints     = var.private_path_service_endpoints
  private_path_zonal_affinity        = var.private_path_zonal_affinity
  private_path_publish               = var.private_path_publish
  private_path_account_policies      = var.private_path_account_policies
}
