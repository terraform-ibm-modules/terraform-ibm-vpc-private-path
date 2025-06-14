#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

locals {
  prefix                    = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  network_loadbalancer_name = "${local.prefix}${var.network_loadbalancer_name}"
  private_path_name         = "${local.prefix}${var.private_path_name}"
  subnet_id                 = var.existing_subnet_id != null ? var.existing_subnet_id : data.ibm_is_vpc.vpc[0].subnets[0].id
  # tflint-ignore: terraform_unused_declarations
  validate_number_of_subnets = var.existing_vpc_id != null ? length(data.ibm_is_vpc.vpc[0].subnets) > 0 ? true : tobool("Existing VPC should have atleast one subnet.") : true
}

data "ibm_is_vpc" "vpc" {
  count      = var.existing_vpc_id != null && var.existing_subnet_id == null ? 1 : 0
  identifier = var.existing_vpc_id
}

module "private_path" {
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  subnet_id                          = local.subnet_id
  tags                               = var.private_path_tags
  access_tags                        = var.private_path_access_tags
  nlb_name                           = local.network_loadbalancer_name
  nlb_backend_pools                  = var.network_loadbalancer_backend_pools
  private_path_name                  = local.private_path_name
  private_path_default_access_policy = var.private_path_default_access_policy
  private_path_service_endpoints     = var.private_path_service_endpoints
  private_path_zonal_affinity        = var.private_path_zonal_affinity
  private_path_publish               = var.private_path_publish
  private_path_account_policies      = var.private_path_account_policies
}
