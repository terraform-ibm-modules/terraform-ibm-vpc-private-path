##############################################################################
# Outputs
##############################################################################

output "existing_subnet_id" {
  value       = ibm_is_subnet.provider_subnet.id
  description = "The subnet ID."
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name."
}

output "vpc_crn" {
  value       = ibm_is_vpc.provider_vpc.crn
  description = "VPC CRN."
}
