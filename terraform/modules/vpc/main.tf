# Create the VPC for the app

module "vpc" {
  # version = "~> 1.66.0"
  # version = "~> 2.0"
  version = "~> 3.0"

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

  # enable_s3_endpoint       = true
  # enable_dynamodb_endpoint = false

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

# module "vpc_endpoints" {
#   source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [data.aws_security_group.default.id]

#   endpoints = {
#     s3 = {
#       service = "s3"
#       tags    = { Name = "s3-vpc-endpoint" }
#     },
#     # dynamodb = {
#     #   service         = "dynamodb"
#     #   service_type    = "Gateway"
#     #   route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
#     #   policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
#     #   tags            = { Name = "dynamodb-vpc-endpoint" }
#     # },
#     # ssm = {
#     #   service             = "ssm"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ssmmessages = {
#     #   service             = "ssmmessages"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # lambda = {
#     #   service             = "lambda"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ecs = {
#     #   service             = "ecs"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ecs_telemetry = {
#     #   service             = "ecs-telemetry"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ec2 = {
#     #   service             = "ec2"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ec2messages = {
#     #   service             = "ec2messages"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # ecr_api = {
#     #   service             = "ecr.api"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     #   policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     # },
#     # ecr_dkr = {
#     #   service             = "ecr.dkr"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     #   policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     # },
#     # kms = {
#     #   service             = "kms"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # codedeploy = {
#     #   service             = "codedeploy"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#     # codedeploy_commands_secure = {
#     #   service             = "codedeploy-commands-secure"
#     #   private_dns_enabled = true
#     #   subnet_ids          = module.vpc.private_subnets
#     # },
#   }

#   tags = merge(
#     {
#       "Name"  = var.app_name
#       "org"   = var.org
#       "app"   = var.app_name
#       "env"   = var.env
#       "owner" = var.owner
#     },
#     var.extra_tags,
#   )
# }

# module "vpc_endpoints_nocreate" {
#   source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

#   create = false
# }


# Private DNS zone for app in VPC
resource "aws_route53_zone" "this" {
  count = var.enable_route53 ? 1 : 0
  name  = var.private_dns_domain == "" ? "${var.app_name}.internal" : var.private_dns_domain

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
