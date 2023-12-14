# Create KMS CMK

# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//kms"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   enable_ec2_as = true
# }

# terragrunt import aws_kms_key.default 91a26962-814a-4f05-bed0-d3c23fb41475
# terragrunt import aws_kms_alias.default alias/webapp-stg

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  name       = var.name == "" ? "${var.app_name}-${var.env}" : var.name
}

# Define key policy for CMK
data "aws_iam_policy_document" "default" {
  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html

  # Ensure root user for AWS account can manage key
  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    resources = ["*"]
  }

  # statement {
  #   sid = "Allow access for Key Administrators"
  #   actions = [
  #     "kms:Create*",
  #     "kms:Describe*",
  #     "kms:Enable*",
  #     "kms:List*",
  #     "kms:Put*",
  #     "kms:Update*",
  #     "kms:Revoke*",
  #     "kms:Disable*",
  #     "kms:Get*",
  #     "kms:Delete*",
  #     "kms:TagResource",
  #     "kms:UntagResource",
  #     "kms:ScheduleKeyDeletion",
  #     "kms:CancelKeyDeletion"
  #   ]
  #   principals {
  #     type        = "AWS"
  #     identifiers = [
  #       "arn:aws:iam::${local.account_id}:role/KMSAdmins"
  #       # "arn:aws:iam::${local.account_id}:user/KMSAdminUser",
  #       # "arn:aws:iam::${local.account_id}:role/KMSAdminRole"
  #     ]
  #   }
  #   resources = ["*"]
  # }

  # Allow ASG to mount instances with encrypted EBS volumes
  # https://docs.aws.amazon.com/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html
  # https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-service-linked-role.html
  # https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html
  dynamic "statement" {
    for_each = var.enable_ec2_as ? tolist([1]) : []
    content {
      sid = "Allow AWS service role for auto scaling to use CMK"
      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        ]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = var.enable_ec2_as ? tolist([1]) : []
    content {
      sid = "Allow attachment of persistent resources"
      principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        ]
      }
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }
}

resource "aws_kms_key" "default" {
  description = local.name

  # deletion_window_in_days = 30 # default
  policy       = data.aws_iam_policy_document.default.json
  multi_region = var.multi_region

  tags = merge(
    {
      "Name"  = format("%s-%s-key", var.app_name, var.env)
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

resource "aws_kms_alias" "default" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.default.arn
}

# data "aws_iam_policy_document" "kms" {
#   statement {
#     sid = "AllowUseOfTheKey"
#
#     # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey",
#     ]
#
#     resources = [aws_kms_key.key.arn]
#   }
# }
