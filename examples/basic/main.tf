########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# VPC
##############################################################################

resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

########################################################################################################################
# Private Path
########################################################################################################################

module "private_path" {
  source                         = "../.."
  resource_group_id              = module.resource_group.resource_group_id
  subnet_id                      = ibm_is_subnet.testacc_subnet.id
  nlb_name                       = "${var.prefix}-nlb"
  private_path_name              = "${var.prefix}-pp"
  private_path_service_endpoints = ["test.example.com"]
}
