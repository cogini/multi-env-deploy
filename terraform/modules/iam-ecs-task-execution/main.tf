# Create IAM Task Execution role for ECS

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html

data "aws_caller_identity" "current" {}

# Configure access to SSM Parameter Store parameters
locals {
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
  ssm_ps_arn = "arn:${var.aws_partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter"
  ssm_ps_param_prefix = var.ssm_ps_param_prefix == "" ? "${var.org}/${var.app_name}/${var.env}/${var.comp}" : var.ssm_ps_param_prefix
  ssm_ps_resources = [for name in var.ssm_ps_params: "${local.ssm_ps_arn}/${local.ssm_ps_param_prefix}/${name}"]
  configure_ssm_ps = length(local.ssm_ps_resources) > 0
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

# Allow task execution role to be assumed by ecs
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.app_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

# Minimum permissions
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow creation of CloudWatch Logs log group
data "aws_iam_policy_document" "cloudwatch-logs" {
  count = var.cloudwatch_logs_create_group ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = local.cloudwatch_logs
  }
}

resource "aws_iam_policy" "cloudwatch-logs" {
  count       = var.cloudwatch_logs_create_group ? 1 : 0
  name_prefix = "${var.app_name}-${var.comp}-cloudwatch-logs-"
  description = "Enable CloudWatch Logs create group"
  policy      = data.aws_iam_policy_document.cloudwatch-logs[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch-logs" {
  count       = var.cloudwatch_logs_create_group ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cloudwatch-logs[0].arn
}


# Allow read only access to SSM Parameter Store params
data "aws_iam_policy_document" "ssm-ps" {
  count = local.configure_ssm_ps ? 1 : 0

  # Allow read only access to SSM Parameter Store params
  dynamic "statement" {
    for_each = local.ssm_ps_resources
    content {
      actions = [
        # "ssm:DescribeParameters",
        "ssm:GetParameters",
        # "ssm:GetParameter*"
      ]
      resources = local.ssm_ps_resources
    }
  }
}

resource "aws_iam_policy" "ssm-ps" {
  count       = local.configure_ssm_ps ? 1 : 0
  name_prefix = "${var.app_name}-${var.comp}-ssm-ps"
  description = "Enable instances to access SSM Parameter Store"
  policy      = data.aws_iam_policy_document.ssm-ps[0].json
}

resource "aws_iam_role_policy_attachment" "ssm-ps" {
  count      = local.configure_ssm_ps ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ssm-ps[0].arn
}


# KMS for SSM PS
# Allow reading parameters encrypted using CMK
# https://docs.aws.amazon.com/kms/latest/developerguide/services-parameter-store.html
# https://docs.aws.amazon.com/kms/latest/developerguide/kms-api-permissions-reference.html
# https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
data "aws_iam_policy_document" "kms" {
  count = var.kms_key_arn != null ? 1 : 0

  statement {
    sid = "AllowKMSForParameterStoreSecrets"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_policy" "kms" {
  count       = var.kms_key_arn != null ? 1 : 0
  name_prefix = "${var.app_name}-${var.comp}-kms-"
  description = "Allow reading SSM PS parameters encrypted using CMK"
  policy      = data.aws_iam_policy_document.kms[0].json
}

resource "aws_iam_role_policy_attachment" "kms" {
  count      = var.kms_key_arn != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.kms[0].arn
}
