# Create IAM ECS task role for app

data "terraform_remote_state" "s3" {
  for_each = toset(keys(var.s3_buckets))
  backend  = "s3"
  config = {
    bucket = var.remote_state_s3_bucket_name
    key    = "${var.remote_state_s3_key_prefix}/${each.key}/terraform.tfstate"
    # key    = "${var.remote_state_s3_key_prefix}/${var.aws_region}/${var.env}/${each.key}/terraform.tfstate"
    region = var.remote_state_s3_bucket_region
  }
}

# Give access to S3 buckets
locals {
  bucket_names = {
    for comp, buckets in var.s3_buckets :
    comp => keys(buckets)
  }
  # Set default actions and ensure that bucket actually exists
  buckets = {
    for comp, buckets in var.s3_buckets :
    comp => {
      for name, attrs in buckets :
      name => {
        actions = lookup(attrs, "actions", ["s3:ListBucket", "s3:List*", "s3:Get*", "s3:PutObject*", "s3:DeleteObject"])
        bucket  = data.terraform_remote_state.s3[comp].outputs.buckets[name]
      }
      if lookup(data.terraform_remote_state.s3[comp].outputs.buckets, name, "missing") != "missing"
    }
  }
  # Get actions for bucket contents
  bucket_actions_content = flatten([
    for comp, buckets in local.buckets : [
      for name, attrs in buckets : {
        bucket = attrs["bucket"]
        actions = [for action in attrs["actions"] : action
        if !contains(["s3:ListBucket", "s3:GetEncryptionConfiguration"], action)]
      }
    ]
  ])
  bucket_actions = flatten([
    for comp, buckets in local.buckets : [
      for name, attrs in buckets : {
        bucket = attrs["bucket"]
        actions = [for action in attrs["actions"] : action
        if contains(["s3:ListBucket", "s3:GetEncryptionConfiguration"], action)]
      }
    ]
  ])
  configure_s3 = length(local.bucket_names) > 0
}

data "aws_caller_identity" "current" {}

# Configure access to SSM Parameter Store parameters
locals {
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
  ssm_ps_arn          = "arn:${var.aws_partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter"
  ssm_ps_param_prefix = var.ssm_ps_param_prefix == "" ? "${var.org}/${var.app_name}/${var.env}/${var.comp}" : var.ssm_ps_param_prefix
  ssm_ps_resources    = [for name in var.ssm_ps_params : "${local.ssm_ps_arn}/${local.ssm_ps_param_prefix}/${name}"]
  configure_ssm_ps    = length(local.ssm_ps_resources) > 0
}

# Override var.app_name
locals {
  name = var.name == "" ? "${var.app_name}" : var.name
}

# Configure access to CloudWatch metrics
locals {
  configure_cloudwatch_metrics  = var.cloudwatch_metrics_namespace != ""
  cloudwatch_metrics_namespaces = var.cloudwatch_metrics_namespace == "*" ? [] : [var.cloudwatch_metrics_namespace]
}

# Configure access to CloudWatch Logs
locals {
  cloudwatch_logs_prefix = var.cloudwatch_logs_prefix == "" ? "arn:${var.aws_partition}:logs:*:*" : var.cloudwatch_logs_prefix
  cloudwatch_logs        = [for name in var.cloudwatch_logs : "${local.cloudwatch_logs_prefix}:${name}"]
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

# Allow writing to CloudWatch metrics
# https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazoncloudwatch.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/iam-cw-condition-keys-namespace.html
data "aws_iam_policy_document" "cloudwatch-metrics" {
  count = local.configure_cloudwatch_metrics ? 1 : 0

  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = ["*"]
    dynamic "condition" {
      for_each = local.cloudwatch_metrics_namespaces
      content {
        test     = "StringEquals"
        variable = "cloudwatch:namespace"
        values   = [condition.value]
      }
    }
  }
}

resource "aws_iam_policy" "cloudwatch-metrics" {
  count = local.configure_cloudwatch_metrics ? 1 : 0

  name_prefix = "${local.name}-${var.comp}-cloudwatch-metrics-"
  description = "Enable logging to CloudWatch metrics"
  policy      = data.aws_iam_policy_document.cloudwatch-metrics[0].json
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
      "logs:PutRetentionPolicy",
    ]
    resources = local.cloudwatch_logs
  }

  # In addition, you may want to allow writing directly to a S3 bucket for logs
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Sending-Logs-Directly-To-S3.html
  # Configure that with "buckets", above
}

resource "aws_iam_policy" "cloudwatch-logs" {
  count       = local.configure_cloudwatch_logs ? 1 : 0
  name_prefix = "${local.name}-${var.comp}-cloudwatch-logs-"
  description = "Enable logging to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.cloudwatch-logs[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch-logs" {
  count      = local.configure_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cloudwatch-logs[0].arn
}

data "aws_iam_policy_document" "transcribe" {
  count = var.enable_transcribe ? 1 : 0

  statement {
    actions = [
      "transcribe:StartTranscriptionJob",
      "transcribe:GetTranscriptionJob",
      "transcribe:TagResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "transcribe" {
  count = var.enable_transcribe ? 1 : 0

  name_prefix = "${local.name}-${var.comp}-transcribe-"
  description = "Allow performing Transcribe jobs"
  policy      = data.aws_iam_policy_document.transcribe[0].json
}

# Give access to S3 buckets
data "aws_iam_policy_document" "s3" {
  count = local.configure_s3 ? 1 : 0

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
  name_prefix = "${local.name}-${var.comp}-s3-"
  description = "Allow access to S3 buckets"
  policy      = data.aws_iam_policy_document.s3[0].json
}

# Allow access to SSM for management
# https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html
# https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html
data "aws_iam_policy_document" "ssm" {
  count = local.configure_ssm_ps ? 1 : 0

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
  count       = local.configure_ssm_ps ? 1 : 0
  name_prefix = "${local.name}-${var.comp}-ssm-"
  description = "Enable instances to access SSM"
  policy      = data.aws_iam_policy_document.ssm[0].json
}

# allow access to ssmmessages for secure connection
data "aws_iam_policy_document" "ssmmessages" {
  count = var.enable_ssmmessages ? 1 : 0

  # allow read only access to ssm parameter store params
  dynamic "statement" {
    for_each = local.ssm_ps_resources
    content {
      actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "ssmmessages" {
  count       = var.enable_ssmmessages ? 1 : 0
  name_prefix = "${local.name}-${var.comp}-ssmmessages-"
  description = "Allow access to ssmmessages for secure connection"
  policy      = data.aws_iam_policy_document.ssmmessages[0].json
}

# SES
data "aws_iam_policy_document" "ses" {
  count = var.enable_ses ? 1 : 0

  statement {
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses" {
  count = var.enable_ses ? 1 : 0

  name_prefix = "${local.name}-${var.comp}-ses-"
  description = "Allow sending ses"
  policy      = data.aws_iam_policy_document.ses[0].json
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
  name_prefix = "${local.name}-${var.comp}-kms-"
  description = "Enable instances to access KMS CMK"
  policy      = data.aws_iam_policy_document.kms[0].json
}

# KMS for SSM PS
# https://docs.aws.amazon.com/kms/latest/developerguide/services-parameter-store.html
# Allow reading parameters encrypted using CMK
# dynamic "statement" {
#   for_each = var.kms_key_arn != null ? tolist([1]) : []
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
#   for_each = var.has_kms ? tolist([1]) : []
#   content {
#     actions   = ["kms:GenerateDataKey"]
#     resources = ["*"]
#   }
# }

# Base IAM role
data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

# Base IAM role
# https://github.com/hashicorp/terraform/issues/2761
resource "aws_iam_role" "this" {
  name_prefix = "${local.name}-${var.comp}-"
  description = "${local.name} ${var.comp} task role"
  # path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json

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
#   name              = "${local.name}-${var.comp}-kms"
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

resource "aws_iam_role_policy_attachment" "cloudwatch-metrics" {
  count      = local.configure_cloudwatch_metrics ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cloudwatch-metrics[0].arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = local.configure_ssm_ps ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ssm[0].arn
}

resource "aws_iam_role_policy_attachment" "ssmmessages" {
  count      = var.enable_ssmmessages ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ssmmessages[0].arn
}

resource "aws_iam_role_policy_attachment" "transcribe" {
  count      = var.enable_transcribe ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.transcribe[0].arn
}

resource "aws_iam_role_policy_attachment" "ses" {
  count      = var.enable_ses ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ses[0].arn
}

# Allow uploading segment documents and telemetry to the X-Ray API
# https://docs.aws.amazon.com/xray/latest/devguide/security_iam_id-based-policy-examples.html
resource "aws_iam_role_policy_attachment" "xray" {
  count      = var.xray ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/AWSXRayDaemonWriteAccess"
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
