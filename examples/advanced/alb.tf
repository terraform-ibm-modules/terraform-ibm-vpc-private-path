##############################################################################
# ALB VPC
##############################################################################


resource "ibm_is_vpc" "alb_vpc" {
  name = "${var.prefix}-alb-vpc"
}

resource "ibm_is_vpc_address_prefix" "alb_prefix" {
  name = "${var.prefix}-prefix"
  zone = "${var.region}-1"
  vpc  = ibm_is_vpc.alb_vpc.id
  cidr = "10.100.10.0/24"
}

resource "ibm_is_subnet" "alb_subnet" {
  depends_on = [
    ibm_is_vpc_address_prefix.alb_prefix
  ]
  name            = "${var.prefix}-provider-vpc"
  vpc             = ibm_is_vpc.alb_vpc.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.100.10.0/24"
  tags            = var.resource_tags
}

resource "ibm_is_instance" "alb_vsi" {
  count   = 2
  name    = "${var.prefix}-alb-vsi-${count.index}"
  image   = data.ibm_is_image.image.id
  profile = "bx2-2x8"

  primary_network_attachment {
    name = "${var.prefix}-alb-vsi-${count.index}"
    virtual_network_interface {
      subnet = ibm_is_subnet.alb_subnet.id
    }
  }

  vpc       = ibm_is_vpc.alb_vpc.id
  zone      = "${var.region}-1"
  keys      = [ibm_is_ssh_key.public_key.id]
  user_data = file("./userdata.sh")
}

resource "ibm_is_lb" "alb" {
  name           = "${var.prefix}-load-balancer"
  resource_group = module.resource_group.resource_group_id
  subnets        = [ibm_is_subnet.alb_subnet.id]
  type           = "private"
}

resource "ibm_is_lb_pool" "alb_backend_pool" {
  name           = "${var.prefix}-alb-pool"
  lb             = ibm_is_lb.alb.id
  algorithm      = "round_robin"
  protocol       = "http"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "http"
}
