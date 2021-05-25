# Create the VPC for the app

module "vpc" {
  version = "~> 3.0.0"

  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source = "terraform-aws-modules/vpc/aws"

  name = var.app_name

  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  azs = var.availability_zones

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  map_public_ip_on_launch = true

  enable_vpn_gateway = var.enable_vpn_gateway
  amazon_side_asn    = var.amazon_side_asn
  customer_gateways = var.customer_gateways

  tags = merge(
    {
      "Name"  = var.app_name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )

  public_subnet_tags = merge({"type" = "public"}, var.public_subnet_tags)
  private_subnet_tags = merge({"type" = "private"}, var.private_subnet_tags)
  database_subnet_tags = merge({"type" = "db"}, var.database_subnet_tags)
  elasticache_subnet_tags = merge({"type" = "elasticache"}, var.elasticache_subnet_tags)
  public_route_table_tags  = var.public_route_table_tags
  private_route_table_tags = var.private_route_table_tags
}

# Private DNS zone for app in VPC
resource "aws_route53_zone" "this" {
  count = var.enable_route53 ? 1 : 0
  name  = var.private_dns_domain == "" ? "${var.app_name}.internal" : var.private_dns_domain

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

# For VPC endpoints check
# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/modules/vpc-endpoints
# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc
module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service = "s3"
      service_type = "Gateway"
      private_dns_enabled = true
      tags    = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service = "dynamodb"
      service_type = "Gateway"
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags = { Name = "dynamodb-vpc-endpoint" }
    }
  }

  tags = merge(
    {
      "Name"  = var.app_name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )

}
