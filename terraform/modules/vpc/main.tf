# Create the VPC for the app

module "vpc" {
  # version = "~> 1.66.0"
  version = "~> 2.0"

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

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false

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
