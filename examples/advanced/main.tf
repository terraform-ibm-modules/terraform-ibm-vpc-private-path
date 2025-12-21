##############################################################################
# Complete example
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
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
  name = "ibm-ubuntu-24-04-3-minimal-amd64-3"
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

  vpc       = ibm_is_vpc.provider_vpc.id
  zone      = "${var.region}-1"
  keys      = [ibm_is_ssh_key.public_key.id]
  user_data = file("./userdata.sh")
}

resource "ibm_is_subnet_reserved_ip" "vsi_ip" {
  name        = "${var.prefix}-ip"
  subnet      = ibm_is_subnet.provider_subnet.id
  auto_delete = false
}

resource "ibm_is_subnet_reserved_ip" "vsi_ip2" {
  name        = "${var.prefix}-ip2"
  subnet      = ibm_is_subnet.provider_subnet.id
  auto_delete = false
}

module "private_path" {
  source                             = "../.."
  resource_group_id                  = module.resource_group.resource_group_id
  subnet_id                          = ibm_is_subnet.provider_subnet.id
  nlb_name                           = "${var.prefix}-nlb"
  private_path_name                  = "${var.prefix}-pp"
  private_path_service_endpoints     = ["vpc-pps.dev.internal"]
  private_path_default_access_policy = "permit"

  nlb_backend_pools = [
    {
      pool_name                   = "backend-1"
      pool_member_instance_ids    = [for vsi in ibm_is_instance.vsi : vsi.id]
      pool_member_reserved_ip_ids = [ibm_is_subnet_reserved_ip.vsi_ip2.reserved_ip]
      pool_member_port            = 80
      pool_health_delay           = 60
      pool_health_retries         = 5
      pool_health_timeout         = 30
      pool_health_type            = "https"
      listener_port               = 80
    },
    {
      pool_name                                = "backend-2"
      pool_member_application_load_balancer_id = ibm_is_lb.alb.id
      pool_member_port                         = 80
      pool_health_delay                        = 60
      pool_health_retries                      = 5
      pool_health_timeout                      = 30
      pool_health_type                         = "https"
      listener_port                            = 81
    },
    {
      pool_name                   = "backend-3"
      pool_member_reserved_ip_ids = [ibm_is_subnet_reserved_ip.vsi_ip.reserved_ip]
      pool_member_port            = 80
      pool_health_delay           = 60
      pool_health_retries         = 5
      pool_health_timeout         = 30
      pool_health_type            = "https"
      listener_port               = 82
    }
  ]
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

module "vpe" {
  source            = "terraform-ibm-modules/vpe-gateway/ibm"
  version           = "4.8.8"
  resource_group_id = module.resource_group.resource_group_id
  vpc_id            = ibm_is_vpc.consumer_vpc.id
  cloud_service_by_crn = [
    {
      crn          = module.private_path.private_path_crn
      service_name = "private-path"
  }]
}
