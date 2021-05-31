# Give CodePipeline service roles access to app resources

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-codepipeline-app"
# }
# dependency "iam" {
#   config_path = "../iam-codepipeline"
# }
# dependency "s3-codepipeline" {
#   config_path = "../s3-codepipeline-app"
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
#       # Allow CodeBuild to run "aws s3 sync" to copy files
#       assets = {}
#     }
#   }
#
#   # Give access to all SSM Parameter Store params under /org/app/env/comp
#   # ssm_ps_params = ["*"]
#   # Give access to specific params under prefix
#   ssm_ps_param_prefix = "cogini/foo/test"
#   ssm_ps_params = ["app/*", "worker/*"]
#
#   artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
#   cache_bucket_arn = dependency.s3-codepipeline.outputs.buckets["build_cache"].arn
#
#   codepipeline_service_role_id = dependency.iam.outputs.outputs.codepipeline_service_role_id
#   codedeploy_service_role_id = dependency.iam.outputs.outputs.codedeploy_service_role_id
#   codebuild_service_role_id = dependency.iam.outputs.outputs.codebuild_service_role_id
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

# Configure access to S3 buckets
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
}

data "aws_caller_identity" "current" {}

# Configure access to SSM Parameter Store
locals {
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html
  ssm_ps_arn = "arn:${var.aws_partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter"
  ssm_ps_param_prefix = var.ssm_ps_param_prefix == "" ? "${var.org}/${var.app_name}/${var.env}/${var.comp}" : var.ssm_ps_param_prefix
  ssm_ps_resources = [for name in var.ssm_ps_params: "${local.ssm_ps_arn}/${local.ssm_ps_param_prefix}/${name}"]
  configure_ssm = length(local.ssm_ps_resources) > 0
}

# Give CodeDeploy access to artifacts S3 bucket
data "aws_iam_policy_document" "codedeploy-s3-deploy" {
  statement {
    sid     = "AccessCodePipelineArtifacts"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]
    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codedeploy-s3-deploy" {
  name   = "${var.app_name}-${var.comp}-codedeploy-s3-deploy"
  role   = var.codedeploy_service_role_id
  policy = data.aws_iam_policy_document.codedeploy-s3-deploy.json
}

# Give CodePipeline access to artifacts S3 bucket
data "aws_iam_policy_document" "codepipeline-s3-deploy" {
  statement {
    sid     = "AccessCodePipelineArtifacts"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]
    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline-s3-deploy" {
  name   = "${var.app_name}-${var.comp}-codepipeline-s3-deploy"
  role   = var.codepipeline_service_role_id
  policy = data.aws_iam_policy_document.codepipeline-s3-deploy.json
}

# Give CodePipeline access to build cache S3 bucket
data "aws_iam_policy_document" "codepipeline-s3-build-cache" {
  statement {
    sid     = "AccessCodePipelineArtifacts"
    actions = [
      "s3:List*",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]
    resources = [
      var.cache_bucket_arn,
      "${var.cache_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline-s3-build-cache" {
  name   = "${var.app_name}-${var.comp}-codepipeline-s3-build-cache"
  role   = var.codepipeline_service_role_id
  policy = data.aws_iam_policy_document.codepipeline-s3-build-cache.json
}

# Give CodeBuild access to artifacts S3 bucket
data "aws_iam_policy_document" "codebuild-s3-deploy" {
  statement {
    sid     = "AccessCodePipelineArtifacts"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
    resources = [
      var.artifacts_bucket_arn,
      "${var.artifacts_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild-s3-deploy" {
  name   = "${var.app_name}-${var.comp}-codebuild-s3-deploy"
  role   = var.codebuild_service_role_id
  policy = data.aws_iam_policy_document.codebuild-s3-deploy.json
}

# Allow CodeBuild to write to build cache bucket
data "aws_iam_policy_document" "codebuild-s3-build-cache" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]
    resources = [
      var.cache_bucket_arn,
      "${var.cache_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "codebuild-s3-build-cache" {
  name   = "${var.app_name}-${var.comp}-codebuild-s3-build-cache"
  role   = var.codebuild_service_role_id
  policy = data.aws_iam_policy_document.codebuild-s3-build-cache.json
}

# Allow CodeBuild to access buckets, e.g. to run "aws s3 sync" to copy files
data "aws_iam_policy_document" "codebuild-s3-assets" {
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

  # Allow invalidating CloudFront distributions
  # This is an all or nothing permission, it doesn't depend on resources
  dynamic "statement" {
    for_each = var.cloudfront_create_invalidation ? tolist([1]) : []
    content {
      actions = [
        "cloudfront:CreateInvalidation"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_iam_role_policy" "codebuild-s3-assets" {
  count  = length(var.s3_buckets) > 0 ? 1 : 0
  name   = "${var.app_name}-${var.comp}-codebuild-s3-assets"
  role   = var.codebuild_service_role_id
  policy = data.aws_iam_policy_document.codebuild-s3-assets.json
}

# Allow access to SSM Parameter Store
data "aws_iam_policy_document" "ssm" {
  count = local.configure_ssm ? 1 : 0

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

resource "aws_iam_policy" "codebuild-ssm" {
  count       = local.configure_ssm ? 1 : 0
  name        = "${var.app_name}-${var.comp}-codebuild-ssm"
  description = "Enable instances to access SSM"
  policy      = data.aws_iam_policy_document.ssm[0].json
}

resource "aws_iam_role_policy_attachment" "codebuild-ssm" {
  count      = local.configure_ssm ? 1 : 0
  role       = var.codebuild_service_role_id
  policy_arn = aws_iam_policy.codebuild-ssm[0].arn
}
