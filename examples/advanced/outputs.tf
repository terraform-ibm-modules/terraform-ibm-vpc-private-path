# ########################################################################################################################
# # Outputs
# ########################################################################################################################

output "lb_crn" {
  description = "The CRN for this load balancer."
  value       = module.private_path.lb_crn
}

output "private_path_crn" {
  description = "The CRN for this private path service gateway."
  value       = module.private_path.private_path_crn
}
