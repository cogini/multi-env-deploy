# Create IAM policy allowing deploy of app using CodeDeploy
#
# This can be added to a user or instance profile (e.g. devops instance)
# allowing them to create CodeDeploy revisions and deploy them.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-codedeploy"
# }
# dependency "iam" {
#   config_path = "../iam-instance-profile-devops"
# }
# dependency "s3-codepipeline" {
#   config_path = "../s3-codepipeline-app"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
#   role_name = dependency.iam.outputs.role_name
# }

data "aws_caller_identity" "current" {
}

locals {
  codedeploy_arn = "arn:${var.aws_partition}:codedeploy:${var.aws_region}:${data.aws_caller_identity.current.account_id}"
}

# Allow users to deploy apps.
#
# It can be given to individual users, e.g. developers or ops, or
# added to the devops instance profile
#
data "aws_iam_policy_document" "codedeploy-app-deploy" {
  # Allow to create deployment
  #
  # Deployment group names follow the naming convention in codedeploy-deployment,
  # but we don't reference the outputs of that module because we build IAM roles first
  statement {
    actions   = ["codedeploy:CreateDeployment"]
    resources = ["${local.codedeploy_arn}:deploymentgroup:${var.app_name}-${var.comp}-*/*"]
  }
  statement {
    actions   = ["codedeploy:GetDeploymentConfig"]
    resources = ["${local.codedeploy_arn}:deploymentconfig:${var.app_name}-${var.comp}-*"]
  }
  statement {
    actions   = ["codedeploy:GetApplicationRevision"]
    resources = ["${local.codedeploy_arn}:application:${var.app_name}-${var.comp}"]
  }
  statement {
    actions   = ["codedeploy:RegisterApplicationRevision"]
    resources = ["${local.codedeploy_arn}:application:${var.app_name}-${var.comp}"]
  }

  # Allow to write revision to deploy bucket
  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "${var.artifacts_bucket_arn}/*",
    ]
  }
  statement {
    actions = ["s3:PutObject*"]
    resources = [
      var.artifacts_bucket_arn,
    ]
  }
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codedeploy-app-deploy" {
  name        = "${var.app_name}-codedeploy-app-deploy"
  description = "Create CodeDeploy revision for app and deploy to app-deploy S3 bucket"
  policy      = data.aws_iam_policy_document.codedeploy-app-deploy.json
}

resource "aws_iam_role_policy_attachment" "codedeploy-app-deploy" {
  role       = var.role_name
  policy_arn = aws_iam_policy.codedeploy-app-deploy.arn
}
