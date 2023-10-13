# Create the VPC for the app

# https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete

data "aws_availability_zones" "available" {}

locals {
  name = var.app_name
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

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

  azs                 = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  create_database_subnet_group  = var.create_database_subnet_group
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  customer_gateways  = var.customer_gateways
  enable_vpn_gateway = var.enable_vpn_gateway
  amazon_side_asn    = var.amazon_side_asn

  map_public_ip_on_launch = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "${local.name}.local"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  tags = local.tags

  public_subnet_tags       = merge({ "type" = "public" }, var.public_subnet_tags)
  private_subnet_tags      = merge({ "type" = "private" }, var.private_subnet_tags)
  database_subnet_tags     = merge({ "type" = "db" }, var.database_subnet_tags)
  elasticache_subnet_tags  = merge({ "type" = "elasticache" }, var.elasticache_subnet_tags)
  public_route_table_tags  = var.public_route_table_tags
  private_route_table_tags = var.private_route_table_tags
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  # https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html
  # https://aws.amazon.com/blogs/containers/using-vpc-endpoint-policies-to-control-amazon-ecr-access/
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
  # endpoints = var.endpoints
  endpoints = {
    s3 = {
      service         = "s3"
      tags            = { Name = "s3-vpc-endpoint" }
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    },
    # codedeploy = {
    #   service             = "codedeploy"
    #   private_dns_enabled = true
    #   subnet_ids          = module.vpc.private_subnets
    # },
    # codedeploy_commands_secure = {
    #   service             = "codedeploy-commands-secure"
    #   private_dns_enabled = true
    #   subnet_ids          = module.vpc.private_subnets
    # },
    # dynamodb = {
    #   service         = "dynamodb"
    #   service_type    = "Gateway"
    #   route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    #   policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
    #   tags            = { Name = "dynamodb-vpc-endpoint" }
    # },
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch-logs-and-interface-VPC.html
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "logs-vpc-endpoint" }
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs = {
      service             = "ecs"
      tags                = { Name = "ecs-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      service             = "ecs-telemetry"
      tags                = { Name = "ecs-telemetry-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      tags                = { Name = "ecr-api-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      # policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      tags                = { Name = "ecr-dkr-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      # policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    # kms = {
    #   service             = "kms"
    #   private_dns_enabled = true
    #   subnet_ids          = module.vpc.private_subnets
    # },
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/vpc-interface-endpoints.html
    rds = {
      service             = "rds"
      tags                = { Name = "rds-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.rds.id]
    },
    ssm = {
      service             = "ssm"
      tags                = { Name = "ssm-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    # lambda = {
    #   service             = "lambda"
    #   private_dns_enabled = true
    #   subnet_ids          = module.vpc.private_subnets
    # },
    # ec2 = {
    #   service             = "ec2"
    #   private_dns_enabled = true
    #   subnet_ids          = module.vpc.private_subnets
    # },
    # https://docs.aws.amazon.com/xray/latest/devguide/xray-security-vpc-endpoint.html
    xray = {
      service             = "xray"
      tags                = { Name = "xray-vpc-endpoint" }
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
  }

  tags = local.tags
}

module "vpc_endpoints_nocreate" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  create = false
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  count     = var.create_ec2_instance_connect_endpoint ? 1 : 0
  subnet_id = module.vpc.private_subnets[0]
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_iam_policy_document" "ecr_endpoint_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch-logs-and-interface-VPC.html
data "aws_iam_policy_document" "logs_endpoint_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
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

# Private DNS zone for app in VPC
resource "aws_route53_zone" "this" {
  count = var.enable_route53 ? 1 : 0

  name = var.private_dns_domain == "" ? "${var.app_name}.internal" : var.private_dns_domain

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
