########################################################################################################################
# Outputs
########################################################################################################################
output "lb_crn" {
  description = "The CRN for this load balancer."
  value       = ibm_is_lb.ppnlb.crn
}

output "lb_id" {
  description = "The unique identifier of the load balancer."
  value       = ibm_is_lb.ppnlb.id
}

output "pool_id" {
  description = "The unique identifier of the load balancer pool."
  value = { for key, value in ibm_is_lb_pool.pool :
  key => value.id }
}

output "pool_member_id" {
  description = "The unique identifier of the load balancer pool member."
  value = { for key, value in ibm_is_lb_pool_member.nlb_pool_members :
  key => value.id }
}

output "listener_id" {
  description = "The unique identifier of the load balancer listener."
  value = { for key, value in ibm_is_lb_listener.listener :
  key => value.id }
}

output "private_path_crn" {
  description = "The CRN for this private path service gateway."
  value       = ibm_is_private_path_service_gateway.private_path.crn
}

output "private_path_id" {
  description = "The unique identifier of the PrivatePathServiceGateway."
  value       = ibm_is_private_path_service_gateway.private_path.id
}

output "private_path_vpc" {
  description = "The VPC this private path service gateway resides in."
  value       = ibm_is_private_path_service_gateway.private_path.vpc
}

output "account_policy_id" {
  description = "The unique identifier of the PrivatePathServiceGatewayAccountPolicy."
  value = length(var.private_path_account_policies) != 0 ? [for id in ibm_is_private_path_service_gateway_account_policy.private_path_account_policies :
  id] : null
}
