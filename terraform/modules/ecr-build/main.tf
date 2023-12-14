# Create ECR repository
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//ecr-build"
# }
# dependencies {
#   paths = []
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#   cross_accounts = [
#     "arn:aws:iam::111111111111:root",
#     "arn:aws:iam::222222222222:root"
#   ]
# }

locals {
  name = var.name == "" ? "${var.org}/${var.app_name}-${var.comp}" : var.name
  configure_policy = var.allow_codebuild || length(var.cross_accounts) > 0
}

# Create repository
# https://www.terraform.io/docs/providers/aws/r/ecr_repository.html
resource "aws_ecr_repository" "this" {
  name = local.name

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
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
}

# Give access to repository
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html
# https://dev.to/aws-builders/new-ecr-pull-through-cache-feature-1b9k
data "aws_iam_policy_document" "this" {
  count = local.configure_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.allow_codebuild ? list([1]) : []
    content {
        sid = "CodeBuildAccess"

        actions = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:BatchImportUpstreamImage",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ]

        principals {
          type        = "Service"
          identifiers = ["codebuild.amazonaws.com"]
        }
    }
  }

  dynamic "statement" {
    for_each = var.cross_accounts

    content {
      sid = "CrossAccountReadOnly"

      principals {
        type        = "AWS"
        identifiers = tolist(var.cross_accounts)
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
        "ecr:ListTagsForResource",
      ]
    }
  }
}

resource "aws_ecr_repository_policy" "this" {
  count = local.configure_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.this[0].json
}

resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each = {
    for index, rule in var.pull_through_cache_rules :
    rule.ecr_repository_prefix => rule
  }

  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
}

# Replication
resource "aws_ecr_replication_configuration" "this" {
  count = var.create_replication ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.registry_replication_rules

      content {
        dynamic "destination" {
          for_each = rule.value.destinations

          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }

        dynamic "repository_filter" {
          for_each = try(rule.value.repository_filters, [])

          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }
}

# Cross-Account registry replication policy
# to be created on the replica side

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_registry_policy" "this" {
  count = length(var.source_account) > 1 ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCrossAccountReplication",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:${var.aws_partition}:iam::${var.source_account}:root"
        },
        Action = [
          "ecr:CreateRepository",
          "ecr:ReplicateImage",
          "ecr:BatchImportUpstreamImage"
        ],
        Resource = [
          "arn:${var.aws_partition}:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
        ]
      }
    ]
  })
}
