##############################################################################
# Outputs
##############################################################################


output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "The name of the Resource Group the instances are provisioned in."
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "The ID of the Resource Group the instances are provisioned in."
}

## Private Path
output "lb_crn" {
  description = "The CRN for this load balancer."
  value       = module.private_path.lb_crn
}

output "lb_id" {
  description = "The unique identifier of the load balancer."
  value       = module.private_path.lb_id
}

output "pool_id" {
  description = "The unique identifier of the load balancer pool."
  value       = module.private_path.pool_id
}

output "pool_member_id" {
  description = "The unique identifier of the load balancer pool member."
  value       = module.private_path.pool_member_id
}

output "listener_id" {
  description = "The unique identifier of the load balancer listener."
  value       = module.private_path.listener_id
}

output "private_path_crn" {
  description = "The CRN for this private path service gateway."
  value       = module.private_path.private_path_crn
}

output "private_path_id" {
  description = "The unique identifier of the PrivatePathServiceGateway."
  value       = module.private_path.private_path_id
}

output "private_path_vpc" {
  description = "The VPC this private path service gateway resides in."
  value       = module.private_path.private_path_vpc
}

output "account_policy_id" {
  description = "The unique identifier of the PrivatePathServiceGatewayAccountPolicy."
  value       = module.private_path.account_policy_id
}
