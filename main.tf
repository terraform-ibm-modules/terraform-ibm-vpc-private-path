##############################################################################
# Load Balancer
##############################################################################

resource "ibm_is_lb" "ppnlb" {
  name           = var.nlb_name
  subnets        = [var.subnet_id]
  type           = "private_path"
  profile        = "network-private-path"
  resource_group = var.resource_group_id
  tags           = var.tags
  access_tags    = var.access_tags
}

##############################################################################


##############################################################################
# Load Balancer Pool
##############################################################################

resource "ibm_is_lb_pool" "pool" {
  lb                  = ibm_is_lb.ppnlb.id
  name                = "${var.nlb_name}-lb-pool"
  algorithm           = var.nlb_pool_algorithm
  protocol            = "tcp"
  health_delay        = var.nlb_pool_health_delay
  health_retries      = var.nlb_pool_health_retries
  health_timeout      = var.nlb_pool_health_timeout
  health_type         = var.nlb_pool_health_type
  health_monitor_port = var.nlb_pool_health_monitor_port
  health_monitor_url  = var.nlb_pool_health_type == "http" ? var.nlb_pool_health_monitor_url : null
}

##############################################################################

##############################################################################
# Load Balancer Pool Member
##############################################################################

locals {
  nlb_pool_members = length(var.nlb_pool_member_instance_ids) != 0 ? flatten([
    for server in var.nlb_pool_member_instance_ids :
    {
      port      = var.nlb_pool_member_port
      lb        = var.nlb_name
      target_id = server
      profile   = "network-private-path"
    }
  ]) : []
}

resource "ibm_is_lb_pool_member" "nlb_pool_members" {
  count     = length(local.nlb_pool_members)
  port      = local.nlb_pool_members[count.index].port
  lb        = ibm_is_lb.ppnlb.id
  pool      = element(split("/", ibm_is_lb_pool.pool.id), 1)
  target_id = local.nlb_pool_members[count.index].target_id
}

##############################################################################

##############################################################################
# Load Balancer Listener
##############################################################################

resource "ibm_is_lb_listener" "listener" {
  lb                    = ibm_is_lb.ppnlb.id
  default_pool          = ibm_is_lb_pool.pool.id
  port_min              = var.nlb_listener_port
  port_max              = var.nlb_listener_port
  protocol              = "tcp"
  accept_proxy_protocol = var.nlb_listener_accept_proxy_protocol
  depends_on            = [ibm_is_lb_pool_member.nlb_pool_members]
}

##############################################################################

##############################################################################
# Private Path
##############################################################################

resource "ibm_is_private_path_service_gateway" "private_path" {
  default_access_policy = var.private_path_default_access_policy
  load_balancer         = ibm_is_lb.ppnlb.id
  service_endpoints     = var.private_path_service_endpoints
  zonal_affinity        = var.private_path_zonal_affinity
  name                  = var.private_path_name
}

resource "ibm_is_private_path_service_gateway_operations" "private_path_publish" {
  published                    = var.private_path_publish
  private_path_service_gateway = ibm_is_private_path_service_gateway.private_path.id
}

resource "ibm_is_private_path_service_gateway_account_policy" "private_path_account_policies" {
  count                        = length(var.private_path_account_policies)
  access_policy                = var.private_path_account_policies[count.index].access_policy
  account                      = var.private_path_account_policies[count.index].account
  private_path_service_gateway = ibm_is_private_path_service_gateway.private_path.id
}
