# Create IAM client role for Cognito IdentityPool
#
# Example:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//iam-cognito-client-role"
# }
# 
# dependency "identity-pool" {
#   config_path = "../cognito-identity-pool-unauth"
# }
# 
# include "root" {
#   path = find_in_parent_folders()
# }
# 
# inputs = {
#   # name = "foo-app" # Default is app_name-comp
#   comp = "app"
# 
#   # application_name = "foo-app" # Default is app_name-comp
# 
#   identity_pool_id = dependency.identity-pool.outputs.id
# }

data "aws_caller_identity" "current" {}

locals {
  name             = var.role_name == "" ? "${var.app_name}-${var.comp}" : var.role_name
  application_name = var.application_name == "" ? local.name : var.application_name
  aws_account_id   = var.aws_account_id == "" ? data.aws_caller_identity.current.account_id : var.aws_account_id
}

data "aws_iam_policy_document" "assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [var.identity_pool_id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = [var.amr]
    }
  }
}

# Allow users to invoke API functions
data "aws_iam_policy_document" "rum" {
  statement {
    effect = "Allow"

    actions = [
      "rum:PutRumEvents",
    ]

    resources = [
      "arn:aws:apigateway:${var.aws_region}::appmonitor/${var.application_name}"
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.name}-cognito-identity"
  description        = "Role for Cognito Identity Pool"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource "aws_iam_policy" "rum" {
  name        = "${local.name}-rum"
  description = "Enable logging to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.rum.json
}

resource "aws_iam_role_policy_attachment" "rum" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.rum.arn
}

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = var.identity_pool_id

  roles = {
    "${var.amr}" = aws_iam_role.this.arn
  }
}
