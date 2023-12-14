locals {
  name = var.app_name
  cidr_blocks = var.cidr_blocks

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

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = local.cidr_blocks
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

