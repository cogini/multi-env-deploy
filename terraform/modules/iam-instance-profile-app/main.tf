# Create IAM instance profile for app or other special purpose instances,
# e.g. devops, bastion

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-instance-profile-app"
# }
# dependency "kms" {
#   config_path = "../kms"
# }
# dependency "s3-codepipeline" {
#   config_path = "../s3-codepipeline-app"
# }
# dependencies {
#   paths = [
#     "../s3-app",
#   ]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   # Give access to S3 buckets
#   s3_buckets = {
#     s3-app = {
#       # assets = {}
#       # Allow read only access to config bucket
#       config = {
#         actions = ["s3:ListBucket", "s3:List*", "s3:Get*"]
#       }
#       data = {}
#       logs = {}
#       protected_web = {}
#       public_web = {}
#       ssm = {
#         actions = ["s3:PutObject", "s3:GetEncryptionConfiguration"]
#       }
#     }
#   }
#
#   # Allow writing to any log group and stream
#   cloudwatch_logs = ["*"]
#   # cloudwatch_logs = ["log-group:*"]
#   # cloudwatch_logs = ["log-group:*:log-stream:*"]
#   # cloudwatch_logs_prefix = "arn:${var.aws_partition}:logs:*:*"
#
#   # Give access to CodeDeploy S3 buckets
#   enable_codedeploy = true
#   artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
#
#   # Enable management via SSM
#   enable_ssm_management = true
#
#   # Give acess to all SSM Parameter Store params under /org/app/env/comp
#   # ssm_ps_params = ["*"]
#   # Specify prefix and params
#   ssm_ps_param_prefix = "/cogini/foo/dev"
#   ssm_ps_params = ["app/*", "worker/*"]
#
#   # Give access to KMS CMK
#   kms_key_arn = dependency.kms.outputs.key_arn
# }

data "terraform_remote_state" "s3" {
  for_each = toset(keys(var.s3_buckets))
  backend = "s3"
  config = {
    bucket = var.remote_state_s3_bucket_name
    key    = "${var.remote_state_s3_key_prefix}/${each.key}/terraform.tfstate"
    region = var.remote_state_s3_bucket_region
  }
}

# Give access to S3 buckets
locals {
  bucket_names = {
    for comp, buckets in var.s3_buckets:
    comp => keys(buckets)
  }
  # Set default actions and ensure that bucket actually exists
  buckets = {
    for comp, buckets in var.s3_buckets:
    comp => {
      for name, attrs in buckets:
        name => {
          actions = lookup(attrs, "actions", ["s3:ListBucket", "s3:List*", "s3:Get*", "s3:PutObject*", "s3:DeleteObject"])
          bucket = data.terraform_remote_state.s3[comp].outputs.buckets[name]
        }
        if lookup(data.terraform_remote_state.s3[comp].outputs.buckets, name, "missing") != "missing"
    }
  }
  # Get actions for bucket contents
  bucket_actions_content = flatten([
    for comp, buckets in local.buckets: [
      for name, attrs in buckets: {
        bucket = attrs["bucket"]
        actions = [for action in attrs["actions"]: action
                   if ! contains(["s3:ListBucket", "s3:GetEncryptionConfiguration"], action)]
      }
    ]
  ])
  bucket_actions = flatten([
    for comp, buckets in local.buckets: [
      for name, attrs in buckets: {
        bucket = attrs["bucket"]
        actions = [for action in attrs["actions"]: action
                   if contains(["s3:ListBucket", "s3:GetEncryptionConfiguration"], action)]
      }
    ]
  ])
  configure_s3 = var.enable_codedeploy || length(local.bucket_names) > 0
}

data "aws_caller_identity" "current" {}

# Configure access to SSM Parameter Store parameters
locals {
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
  ssm_ps_arn = "arn:${var.aws_partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter"
  ssm_ps_param_prefix = var.ssm_ps_param_prefix == "" ? "${var.org}/${var.app_name}/${var.env}/${var.comp}" : var.ssm_ps_param_prefix
  ssm_ps_resources = [for name in var.ssm_ps_params: "${local.ssm_ps_arn}/${local.ssm_ps_param_prefix}/${name}"]
  configure_ssm = length(local.ssm_ps_resources) > 0 || var.enable_ssm_management
}

# Configure access to CloudWatch Logs
locals {
  cloudwatch_logs_prefix = var.cloudwatch_logs_prefix == "" ? "arn:${var.aws_partition}:logs:*:*" : var.cloudwatch_logs_prefix
  cloudwatch_logs = [for name in var.cloudwatch_logs: "${local.cloudwatch_logs_prefix}:${name}"]
  # arn:${var.aws_partition}:logs:*:*:*
  # arn:${var.aws_partition}:logs:*:*:log-group:*
  # arn:${var.aws_partition}:logs:*:*:log-group:*:log-stream:*

  # The first * in each string can be replaced with an AWS region name like
  # us-east-1 to grant access only within the given region.
  #
  # The * after log-group in can be replaced with a log group name to grant
  # access only to the named group.
  #
  # The * after log-stream can be replaced with a log stream name to grant
  # access only to the named stream.
  configure_cloudwatch_logs = length(local.cloudwatch_logs) > 0
}

# Allow writing to CloudWatch Logs
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/EC2NewInstanceCWL.html
data "aws_iam_policy_document" "cloudwatch-logs" {
  count = local.configure_cloudwatch_logs ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = local.cloudwatch_logs
  }

  # In addition, you may want to allow writing directly to a S3 bucket for logs
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Sending-Logs-Directly-To-S3.html
  # Configure that with "buckets", above
}

resource "aws_iam_policy" "cloudwatch-logs" {
  count       = local.configure_cloudwatch_logs ? 1 : 0
  name        = "${var.app_name}-${var.comp}-cloudwatch-logs"
  description = "Enable logging to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.cloudwatch-logs[0].json
}

# Give access to S3 buckets
data "aws_iam_policy_document" "s3" {
  count = local.configure_s3 ? 1 : 0

  # CodeDeploy
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/auth-and-access-control.html
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/instances-on-premises.html

  # Allow access to CodeDeploy agent
  dynamic "statement" {
    for_each = var.enable_codedeploy ? list(1) : []
    content {
      actions = ["s3:Get*", "s3:List*"]
      resources = [
        "arn:${var.aws_partition}:s3:::aws-codedeploy-us-east-2/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-us-east-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-us-west-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-us-west-2/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ca-central-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-eu-west-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-eu-west-2/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-eu-west-3/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-eu-central-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ap-northeast-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ap-northeast-2/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ap-southeast-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ap-southeast-2/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-ap-south-1/*",
        "arn:${var.aws_partition}:s3:::aws-codedeploy-sa-east-1/*",
      ]
    }
  }

  # Allow access to artifacts S3 bucket to download CodeDeploy releases
  dynamic "statement" {
    for_each = (var.enable_codedeploy && var.artifacts_bucket_arn != "") ? list(1) : []
    content {
      actions = ["s3:Get*", "s3:List*"]
      # This could be made more specific
      resources = ["${var.artifacts_bucket_arn}/*"]
    }
  }

  # General S3 access configuration

  # Allow ListBucket actions on buckets
  dynamic "statement" {
    for_each = local.bucket_actions
    content {
      actions   = statement.value["actions"]
      resources = [statement.value["bucket"].arn]
    }
  }

  # Allow other actions on buckets
  dynamic "statement" {
    for_each = local.bucket_actions_content
    content {
      actions   = statement.value["actions"]
      resources = ["${statement.value["bucket"].arn}/*"]
    }
  }
}

resource "aws_iam_policy" "s3" {
  count       = local.configure_s3 ? 1 : 0
  name        = "${var.app_name}-${var.comp}-s3"
  description = "Allow access to S3 buckets"
  policy      = data.aws_iam_policy_document.s3[0].json
}

# Allow access to SSM for management
# https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html
# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html
data "aws_iam_policy_document" "ssm" {
  count = local.configure_ssm ? 1 : 0

  dynamic "statement" {
    for_each = var.enable_ssm_management ? list(1) : []
    content {
      sid = "AllowAccessToSSM"
      actions = [
        "ssm:DescribeAssociation",
        "ssm:ListAssociations",
        "ssm:GetDocument",
        "ssm:ListInstanceAssociations",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply",
        "ds:CreateComputer",
        "ds:DescribeDirectories",
        "ec2:DescribeInstanceStatus",
      ]
      resources = ["*"]
    }
  }

  # Give SSM Session Manager access
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-add-permissions-to-existing-profile.html
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html
  dynamic "statement" {
    for_each = var.enable_ssm_management ? list(1) : []
    content {
      actions = [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
      ]
      resources = ["*"]
    }
  }

  # Allow read only access to SSM Parameter Store params
  dynamic "statement" {
    for_each = local.ssm_ps_resources
    content {
      actions = [
        "ssm:DescribeParameters",
        "ssm:GetParameters",
        "ssm:GetParameter*"
      ]
      resources = local.ssm_ps_resources
    }
  }
}

resource "aws_iam_policy" "ssm" {
  count       = local.configure_ssm ? 1 : 0
  name        = "${var.app_name}-${var.comp}-ssm"
  description = "Enable instances to access SSM"
  policy      = data.aws_iam_policy_document.ssm[0].json
}

# KMS
# https://docs.aws.amazon.com/kms/latest/developerguide/kms-api-permissions-reference.html
# https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
data "aws_iam_policy_document" "kms" {
  count = var.kms_key_arn != null ? 1 : 0

  statement {
    sid = "AllowKeyUsage"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "kms" {
  count       = var.kms_key_arn != null ? 1 : 0
  name        = "${var.app_name}-${var.comp}-kms"
  description = "Enable instances to access KMS CMK"
  policy      = data.aws_iam_policy_document.kms[0].json
}

# KMS for SSM PS
# https://docs.aws.amazon.com/kms/latest/developerguide/services-parameter-store.html
# Allow reading parameters encrypted using CMK
# dynamic "statement" {
#   for_each = var.kms_key_arn != null ? list(1) : []
#   content {
#     actions = ["kms:Decrypt", "kms:DescribeKey"]
#     resources = [var.kms_key_arn]
#   }
# }
#
# KMS for S3
# https://docs.aws.amazon.com/kms/latest/developerguide/services-s3.html
#
# ALlow writing encrypted data to S3
# dynamic "statement" {
#   for_each = var.has_kms ? list(1) : []
#   content {
#     actions   = ["kms:GenerateDataKey"]
#     resources = ["*"]
#   }
# }

# Base IAM role
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        var.aws_service_endpoint_ec2,
        # "s3.amazonaws.com",
        # "codedeploy.amazonaws.com",
      ]
    }
  }
}

# Base IAM role
# https://github.com/hashicorp/terraform/issues/2761
resource "aws_iam_role" "this" {
  name               = "${var.app_name}-${var.comp}"
  description        = "${var.app_name} ${var.comp} instance profile"
  # path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json

  # https://github.com/hashicorp/terraform/issues/2761
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }
}

# Allow access to secrets encrypted by the app custom KMS key,
# needed to access encrypted S3 buckets
# resource "aws_kms_grant" "this" {
#   count             = var.kms_key_arn != null ? 1 : 0
#   name              = "${var.app_name}-${var.comp}-kms"
#   key_id            = var.kms_key_arn
#   grantee_principal = aws_iam_role.this.arn
#   operations        = ["Decrypt", "DescribeKey"]
# }

# Allow access to S3 buckets
resource "aws_iam_role_policy_attachment" "s3" {
  count      = local.configure_s3 ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3[0].arn
}

# Allow CodeDeploy to deploy
# resource "aws_iam_role_policy_attachment" "codedeploy-service-policy" {
#   role       = aws_iam_role.this.name
#   policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSCodeDeployRole"
# }

# Allow use of CloudWatch Logs
resource "aws_iam_role_policy_attachment" "cloudwatch-logs" {
  count      = local.configure_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cloudwatch-logs[0].arn
}

# Allow management via SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = local.configure_ssm ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ssm[0].arn
}

resource "aws_iam_role_policy_attachment" "kms" {
  count      = var.kms_key_arn != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.kms[0].arn
}

# Allow component to read parameters from SSM
# This requires fewer permissions than the full SSM management permissions
# https://docs.aws.amazon.com/systems-manager/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html#managed-policies
# resource "aws_iam_role_policy_attachment" "ssm-service-policy" {
#   count      = var.enable_ssm_ps_readonly ? 1 : 0
#   role       = aws_iam_role.this.name
#   policy_arn = "arn:${var.aws_partition}:iam::aws:policy/AmazonSSMReadOnlyAccess"
# }

# Allow listing EC2 instances
# Needed for Prometheus
resource "aws_iam_role_policy_attachment" "ec2-read-only" {
  count      = var.enable_ec2_readonly ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Allow instances to query metadata of other instances
# Needed by custom Elasticsearch
data "aws_iam_policy_document" "describe-instances" {
  statement {
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "describe-instances" {
  count       = var.enable_ec2_describe_instances ? 1 : 0
  name        = "${var.app_name}-${var.comp}-describe-instances"
  description = "Enable instances to query for instance's metadata"
  policy      = data.aws_iam_policy_document.describe-instances.json
}

# Create instance profile for role
resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}
