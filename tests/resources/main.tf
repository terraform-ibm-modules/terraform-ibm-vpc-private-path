################################################################################
# Resource Group
################################################################################
module "resource_group" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.4.0"
  resource_group_name = "${var.prefix}-rg"
}

##############################################################################
# Provider VPC
##############################################################################


resource "ibm_is_vpc" "provider_vpc" {
  name = "${var.prefix}-provider-vpc"
}

resource "ibm_is_vpc_address_prefix" "prefix" {
  name = "${var.prefix}-prefix"
  zone = "${var.region}-1"
  vpc  = ibm_is_vpc.provider_vpc.id
  cidr = "10.100.10.0/24"
}

resource "ibm_is_subnet" "provider_subnet" {
  depends_on = [
    ibm_is_vpc_address_prefix.prefix
  ]
  name            = "${var.prefix}-provider-vpc"
  vpc             = ibm_is_vpc.provider_vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.100.10.0/24"
  tags            = var.resource_tags
}
