locals {
  name_prefix = "${var.project_name}-${var.env}"
  zone        = "${var.region}-1"
  base_tags   = {
    env          = var.env
    "managed-by" = "terraform"
    project      = var.project_name
  }
  # Scaleway VPC/network resources expect tags as list of "key:value" strings
  tag_list = [for k, v in merge(local.base_tags, var.tags) : "${k}:${v}"]
}

resource "scaleway_vpc" "main" {
  name   = "${local.name_prefix}-vpc"
  region = var.region
  tags   = local.tag_list
}

resource "scaleway_vpc_private_network" "main" {
  name   = "${local.name_prefix}-pn"
  vpc_id = scaleway_vpc.main.id
  region = var.region

  ipv4_subnet {
    subnet = var.private_subnet_cidr
  }

  tags = local.tag_list
}

resource "scaleway_vpc_public_gateway_ip" "main" {
  tags = local.tag_list
}

resource "scaleway_vpc_public_gateway" "main" {
  name  = "${local.name_prefix}-pgw"
  type  = var.gateway_type
  ip_id = scaleway_vpc_public_gateway_ip.main.id
  zone  = local.zone
  tags  = local.tag_list
}

# scaleway_vpc_public_gateway_dhcp removed — DHCP is now handled automatically
# by Private Networks (VPC GW v2 migration).

resource "scaleway_vpc_gateway_network" "main" {
  gateway_id         = scaleway_vpc_public_gateway.main.id
  private_network_id = scaleway_vpc_private_network.main.id
  enable_masquerade  = true
  zone               = local.zone
}
