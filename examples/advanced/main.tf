##############################################################################
# Complete example
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
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

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "ibm_is_ssh_key" "public_key" {
  name       = "${var.prefix}-key"
  public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)
}

data "ibm_is_image" "image" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

resource "ibm_is_instance" "vsi" {
  count   = 2
  name    = "${var.prefix}-vsi-${count.index}"
  image   = data.ibm_is_image.image.id
  profile = "bx2-2x8"

  primary_network_attachment {
    name = "${var.prefix}-vsi-${count.index}"
    virtual_network_interface {
      subnet = ibm_is_subnet.provider_subnet.id
    }
  }

  vpc  = ibm_is_vpc.provider_vpc.id
  zone = "${var.region}-1"
  keys = [ibm_is_ssh_key.public_key.id]
}


module "private_path" {
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  subnet_id                          = ibm_is_subnet.provider_subnet.id
  nlb_name                           = "${var.prefix}-nlb"
  private_path_name                  = "${var.prefix}-pp"
  private_path_service_endpoints     = ["vpc-pps.example.com"]
  private_path_default_access_policy = "permit"
  nlb_pool_member_instance_ids       = [for vsi in ibm_is_instance.vsi : vsi.id]
  nlb_pool_member_port               = 80
}

##############################################################################
# Consumer VPC
##############################################################################

resource "ibm_is_vpc" "consumer_vpc" {
  name           = "${var.prefix}-consumer-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "consumer_subnet" {
  name                     = "${var.prefix}-subnet-1"
  vpc                      = ibm_is_vpc.consumer_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

resource "ibm_is_virtual_endpoint_gateway" "vpe" {
  name = "${var.prefix}-consumer-gateway"
  target {
    crn           = module.private_path.private_path_crn
    resource_type = "private_path_service_gateway"
  }
  vpc            = ibm_is_vpc.consumer_vpc.id
  resource_group = module.resource_group.resource_group_id
}
