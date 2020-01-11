# Create Elasticsearch domain

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//elasticsearch"
# }
# # dependency "kms" {
# #   config_path = "../kms"
# # }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "sg" {
#   config_path = "../sg-elasticsearch-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   instance_type = "t2.small.elasticsearch"
#   instance_count = 1
#   elasticsearch_version = "6.3"
#
#   # Encryption at rest is not supported with t2.small.elasticsearch instances
#   # encrypt = true
#   # kms_key_id = dependency.kms.outputs.key_id
#
#   subnet_ids = dependency.vpc.outputs.subnets["database"]
#   private_dns_somain = dependency.vpc.outputs.private_dns_domain
#   security_group_ids = [dependency.sg.outputs.security_group_id]
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  cloudwatch_log_group = var.cloudwatch_log_group == "" ? "${var.app_name}-${var.comp}" : var.cloudwatch_log_group
  subnet_ids = slice(var.subnet_ids, 0, var.instance_count)
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.cloudwatch_log_group
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name     = "elasticsearch"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:${var.aws_partition}:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

# https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-elasticsearch-domain.html
resource "aws_elasticsearch_domain" "this" {
  domain_name           = local.name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    zone_awareness_enabled   = var.zone_awareness_enabled
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.iops
  }

  dynamic "encrypt_at_rest" {
    # It is an error to specify the key if encrypt is false
    for_each = var.encrypt ? list(1) : []
    content {
      enabled    = var.encrypt
      kms_key_id = var.kms_key_id
    }
  }

  node_to_node_encryption {
    enabled = var.encrypt
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  vpc_options {
    subnet_ids = local.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )

  depends_on = [aws_iam_service_linked_role.es]
}
