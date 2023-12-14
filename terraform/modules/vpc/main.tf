# Create the VPC for the app

# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete

data "aws_availability_zones" "available" {}

locals {
  name = var.app_name
  azs = var.availability_zones == [] ? slice(data.aws_availability_zones.available.names, 0, 3) : var.availability_zones

  tags = merge(
    {
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = local.name
  cidr = var.cidr

  azs                 = local.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  create_database_subnet_group  = var.create_database_subnet_group
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  # enable_dns_hostnames = true
  # enable_dns_support   = true

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  customer_gateways  = var.customer_gateways
  enable_vpn_gateway = var.enable_vpn_gateway
  amazon_side_asn    = var.amazon_side_asn

  map_public_ip_on_launch = true

  # enable_dhcp_options              = true
  # dhcp_options_domain_name         = "${local.name}.internal"
  # dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  tags = local.tags

  public_subnet_tags       = merge({ "type" = "public" }, var.public_subnet_tags)
  private_subnet_tags      = merge({ "type" = "private" }, var.private_subnet_tags)
  database_subnet_tags     = merge({ "type" = "db" }, var.database_subnet_tags)
  elasticache_subnet_tags  = merge({ "type" = "elasticache" }, var.elasticache_subnet_tags)
  public_route_table_tags  = var.public_route_table_tags
  private_route_table_tags = var.private_route_table_tags
}

resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = local.tags
}
