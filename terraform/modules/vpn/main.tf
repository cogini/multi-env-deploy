# Create the VPN for given VPC

module "vpn_gateway" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 2.0"

  vpc_id              = var.vpc_id
  vpn_gateway_id      = var.vpc_vgw_id
  customer_gateway_id = var.vpc_cgw_ids

  # precalculated length of module variable vpc_subnet_route_table_ids
  vpc_subnet_route_table_count = 1
  vpc_subnet_route_table_ids   = var.vpc_private_route_table_ids

  # tunnel inside cidr & preshared keys (optional)
  # tunnel1_inside_cidr   = var.custom_tunnel1_inside_cidr
  # tunnel2_inside_cidr   = var.custom_tunnel2_inside_cidr
  # tunnel1_preshared_key = var.custom_tunnel1_preshared_key
  # tunnel2_preshared_key = var.custom_tunnel2_preshared_key
}
