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
  for_each = { for pool in var.nlb_backend_pools :
  pool.pool_name => pool }
  lb                  = ibm_is_lb.ppnlb.id
  name                = each.key
  algorithm           = each.value.pool_algorithm
  protocol            = "tcp"
  health_delay        = each.value.pool_health_delay
  health_retries      = each.value.pool_health_retries
  health_timeout      = each.value.pool_health_timeout
  health_type         = each.value.pool_health_type
  health_monitor_port = each.value.pool_health_monitor_port
  health_monitor_url  = each.value.pool_health_type == "http" ? each.value.pool_health_monitor_url : null
}

##############################################################################

##############################################################################
# Load Balancer Pool Member
##############################################################################

locals {
  pool_listener = { for pool in var.nlb_backend_pools :
    pool.pool_name => merge(pool, { pool_id = ibm_is_lb_pool.pool[pool.pool_name].id })
  }

  # The `ibm_is_lb_pool_member` has a limitation where it can only add one target at a time, hence creating a more complex map with unique objects that have different target IDs.
  pool_members = merge(flatten(concat(
    [
      for pool in var.nlb_backend_pools :
      {
        for count, id in pool.pool_member_instance_ids :
        "${pool.pool_name}-${count}" => merge(pool, { pool_id = ibm_is_lb_pool.pool[pool.pool_name].id }, { target_id = id })
      } if length(pool.pool_member_instance_ids) > 0
    ],
    [
      for pool in var.nlb_backend_pools :
      {
        for count, id in pool.pool_member_reserved_ip_ids :
        "${pool.pool_name}-ips-${count}" => merge(pool, { pool_id = ibm_is_lb_pool.pool[pool.pool_name].id }, { target_id = id })
      } if length(pool.pool_member_reserved_ip_ids) > 0
    ],
    [
      {
        for pool in var.nlb_backend_pools :
        pool.pool_name => merge(pool, { pool_id = ibm_is_lb_pool.pool[pool.pool_name].id }, { target_id = pool.pool_member_application_load_balancer_id })
        if length(pool.pool_member_instance_ids) == 0 && length(pool.pool_member_reserved_ip_ids) == 0
      }
    ]
  ))...)
}

resource "ibm_is_lb_pool_member" "nlb_pool_members" {
  for_each  = local.pool_members
  port      = each.value.pool_member_port
  lb        = ibm_is_lb.ppnlb.id
  pool      = element(split("/", each.value.pool_id), 1)
  target_id = each.value.target_id
}

##############################################################################

##############################################################################
# Load Balancer Listener
##############################################################################

resource "ibm_is_lb_listener" "listener" {
  for_each              = local.pool_listener
  lb                    = ibm_is_lb.ppnlb.id
  default_pool          = each.value.pool_id
  port_min              = each.value.listener_port
  port_max              = each.value.listener_port
  protocol              = "tcp"
  accept_proxy_protocol = each.value.listener_accept_proxy_protocol
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
