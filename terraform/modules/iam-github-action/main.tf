# Create IAM role that allows a GitHub Action to call AWS
#
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://scalesec.com/blog/identity-federation-for-github-actions-on-aws/
# https://stackoverflow.com/questions/69243571/how-can-i-connect-github-actions-with-aws-deployments-without-using-a-secret-key
# https://github.com/aws-actions/aws-codebuild-run-build
# https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/

# Example config:
# include "root" {
#   path = find_in_parent_folders()
# }
#
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//iam-github-action"
# }
#
# dependency "cloudfront" {
#   config_path = "../cloudfront-app-assets"
# }
# dependency "codedeploy-app" {
#   config_path = "../codedeploy-app"
# }
# dependency "codedeploy-deployment" {
#   config_path = "../codedeploy-deployment-app"
# }
# dependency "ecr" {
#   config_path = "../ecr-app"
# }
# dependency "ecs-cluster" {
#   config_path = "../ecs-cluster"
# }
# dependency "ecs-service" {
#   config_path = "../ecs-service-app"
# }
# dependency "iam-ecs-task-execution" {
#   config_path = "../iam-ecs-task-execution"
# }
# dependency "iam-ecs-task-role" {
#   config_path = "../iam-ecs-task-role-app"
# }
# dependency "s3" {
#   config_path = "../s3-app"
# }
#
# inputs = {
#   comp = "app"
#
#   sub = "repo:cogini/foo:*"
#
#   s3_buckets = [
#     dependency.s3.outputs.buckets["assets"].id
#   ]
#
#   enable_cloudfront = true
#
#   ecr_arn = dependency.ecr.outputs.arn
#
#   ecs = {
#     cluster_name = dependency.ecs-cluster.outputs.name
#     service_name = dependency.ecs-service.outputs.name
#     task_role_arn = dependency.iam-ecs-task-role.outputs.arn
#     execution_role_arn = dependency.iam-ecs-task-execution.outputs.arn
#     codedeploy_application_name = dependency.codedeploy-app.outputs.app_name
#     codedeploy_deployment_group_name = dependency.codedeploy-deployment.outputs.deployment_group_name
#   }
# }

data "aws_caller_identity" "current" {}

locals {
  aws_account_id    = var.aws_account_id == "" ? data.aws_caller_identity.current.account_id : var.aws_account_id
  name              = var.name == "" ? "${var.org}-${var.app_name}-${var.env}-${var.comp}" : var.name
  enable_s3         = length(var.s3_buckets) > 0
  enable_cloudfront = var.enable_cloudfront
  enable_ecr        = var.ecr_arn != ""
  enable_ecs        = var.ecs != null
  ecs               = var.ecs
  enable_codebuild  = var.codebuild_project_name != ""
  enable_codedeploy = var.ecs != null && try(var.ecs.codedeploy_application_name, null) != null

  # enable_codedeploy = var.enable_codedeploy
  # codedeploy_arn    = "arn:${var.aws_partition}:codedeploy:${var.aws_region}:${local.aws_account_id}"
  # codedeploy_name   = var.codedeploy_name == "" ? "${var.app_name}-${var.comp}" : var.codedeploy_name
  # codedeploy_deploymentgroup_name = var.codedeploy_deploymentgroup_name == "" ? local.codedeploy_name : var.codedeploy_deploymentgroup_name
  # codedeploy_deploymentconfig_name = var.codedeploy_deploymentconfig_name == "" ? local.codedeploy_name : var.codedeploy_deploymentconfig_name
  # codedeploy_application_name = var.codedeploy_application_name == "" ? local.codedeploy_name : var.codedeploy_application_name
  # codedeploy_bucket = var.codedeploy_bucket
  # codedeploy_bucket_arn = "arn:${var.aws_partition}:s3:::${local.codedeploy_bucket}"
}

resource "aws_iam_role" "this" {
  name               = "${local.name}-github-action"
  description        = "Allow GitHub Action to call AWS services"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:${var.aws_partition}:iam::${local.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "${var.sub}"
        }
      }
    }
  ]
}
EOF
}


# Give access to S3 buckets
data "aws_iam_policy_document" "s3" {
  count = local.enable_s3 ? 1 : 0

  # Allow actions on buckets
  dynamic "statement" {
    for_each = var.s3_buckets
    content {
      actions = [
        "s3:GetBucketLocation",
        "s3:ListBucket",
      ]
      resources = ["arn:${var.aws_partition}:s3:::${statement.value}"]
    }
  }

  # Allow actions on bucket contents
  dynamic "statement" {
    for_each = var.s3_buckets
    content {
      actions = [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
      ]
      resources = ["arn:${var.aws_partition}:s3:::${statement.value}/*"]
    }
  }

  statement {
    actions = [
      "s3:ListObjects"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3" {
  count = local.enable_s3 ? 1 : 0

  name_prefix = "${local.name}-github-action-s3-"
  description = "Allow access to S3 buckets"
  policy      = data.aws_iam_policy_document.s3[0].json
}

resource "aws_iam_role_policy_attachment" "github-action-s3" {
  count = local.enable_s3 ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3[0].arn
}


# Add permissions to create CloudFront invalidation
data "aws_iam_policy_document" "cloudfront" {
  count = local.enable_cloudfront ? 1 : 0

  statement {
    actions = [
      "acm:ListCertificates",
      "cloudfront:GetDistribution",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudfront:ListCloudFrontOriginAccessIdentities",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
      "elasticloadbalancing:DescribeLoadBalancers",
      "iam:ListServerCertificates",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTopics",
      "waf:GetWebACL",
      "waf:ListWebACLs",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudfront" {
  count = local.enable_cloudfront ? 1 : 0

  name_prefix = "${local.name}-github-action-cloudfront"
  description = "Allow GitHub Action to access CloudFront"
  policy      = data.aws_iam_policy_document.cloudfront[0].json
}

resource "aws_iam_role_policy_attachment" "github-action-cloudfront" {
  count = local.enable_cloudfront ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.cloudfront[0].arn
}


# Add permissions to access ECR
data "aws_iam_policy_document" "ecr" {
  count = local.enable_ecr ? 1 : 0

  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [var.ecr_arn]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr" {
  count = local.enable_ecr ? 1 : 0

  name_prefix = "${local.name}-github-action-ecr-"
  description = "Allow GitHub Action to access ECR"
  policy      = data.aws_iam_policy_document.ecr[0].json
}

resource "aws_iam_role_policy_attachment" "github-action-ecr" {
  count = local.enable_ecr ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr[0].arn
}


# Run CodeBuild and get resulting log messages
data "aws_iam_policy_document" "codebuild" {
  count = local.enable_codebuild ? 1 : 0

  statement {
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = ["arn:${var.aws_partition}:codebuild:${var.aws_region}:${local.aws_account_id}:project/${var.codebuild_project_name}"]
  }

  statement {
    actions   = ["logs:GetLogEvents"]
    resources = ["arn:${var.aws_partition}:logs:${var.aws_region}:${local.aws_account_id}:log-group:/aws/codebuild/${var.codebuild_project_name}:*"]
  }
}

resource "aws_iam_policy" "codebuild" {
  count = local.enable_codebuild ? 1 : 0

  name_prefix = "${local.name}-github-action-codebuild-"
  description = "Allow GitHub Action to run CodeBuild"
  policy      = data.aws_iam_policy_document.codebuild[0].json
}

resource "aws_iam_role_policy_attachment" "github-action" {
  count = local.enable_codebuild ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.codebuild[0].arn
}


# Deploy via ECS
# https://github.com/aws-actions/amazon-ecs-deploy-task-definition
data "aws_iam_policy_document" "ecs" {
  count = local.enable_ecs ? 1 : 0

  statement {
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      local.ecs.task_role_arn,
      local.ecs.execution_role_arn
    ]
  }

  statement {
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = [
      "arn:${var.aws_partition}:ecs:${var.aws_region}:${local.aws_account_id}:service/${local.ecs.cluster_name}/${local.ecs.service_name}"
    ]
  }

  # When using CodeDeploy, "ecs:UpdateService" is not needed
  # dynamic "statement" {
  #   for_each = local.enable_codedeploy ? [] : tolist([1])
  #   content {
  #     actions   = [
  #       "ecs:UpdateService",
  #       "ecs:DescribeServices"
  #     ]
  #     resources = [
  #       "arn:${var.aws_partition}:ecs:${var.aws_region}:${local.aws_account_id}:service/${local.ecs.cluster_name}/${local.ecs.service_name}"
  #     ]
  #   }
  # }
  #
  # dynamic "statement" {
  #   for_each = local.enable_codedeploy ? tolist([1]) : []
  #   content {
  #     actions   = [
  #       "ecs:DescribeServices"
  #     ]
  #     resources = [
  #       "arn:${var.aws_partition}:ecs:${var.aws_region}:${local.aws_account_id}:service/${local.ecs.cluster_name}/${local.ecs.service_name}"
  #     ]
  #   }
  # }

  dynamic "statement" {
    for_each = local.enable_codedeploy ? tolist([1]) : []
    content {
      actions = [
        "codedeploy:GetDeploymentGroup",
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision"
      ]
      resources = [
        "arn:${var.aws_partition}:codedeploy:${var.aws_region}:${local.aws_account_id}:deploymentgroup:${local.ecs.codedeploy_application_name}/${local.ecs.codedeploy_deployment_group_name}",
        "arn:${var.aws_partition}:codedeploy:${var.aws_region}:${local.aws_account_id}:deploymentconfig:*",
        "arn:${var.aws_partition}:codedeploy:${var.aws_region}:${local.aws_account_id}:application:${var.ecs.codedeploy_application_name}"
      ]
    }
  }
}

resource "aws_iam_policy" "ecs" {
  count = local.enable_ecs ? 1 : 0

  name_prefix = "${local.name}-github-action-ecs-"
  description = "Deploy to ECS"
  policy      = data.aws_iam_policy_document.ecs[0].json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  count = local.enable_ecs ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecs[0].arn
}


# Create CodeDeploy deployment
# data "aws_iam_policy_document" "codedeploy-app-deploy" {
#   count = local.enable_codedeploy ? 1 : 0
#
#   statement {
#     actions   = ["codedeploy:CreateDeployment"]
#     resources = ["${local.codedeploy_arn}:deploymentgroup:${local.codedeploy_deploymentgroup_name}*/*"]
#   }
#   statement {
#     actions   = ["codedeploy:GetDeploymentConfig"]
#     resources = ["${local.codedeploy_arn}:deploymentconfig:${local.codedeploy_deploymentconfig_name}*"]
#   }
#   statement {
#     actions   = ["codedeploy:GetApplicationRevision"]
#     resources = ["${local.codedeploy_arn}:application:${local.codedeploy_application_name}"]
#   }
#   statement {
#     actions   = ["codedeploy:RegisterApplicationRevision"]
#     resources = ["${local.codedeploy_arn}:application:${local.codedeploy_application_name}"]
#   }
#
#   # Allow writing revision to deploy bucket
#   statement {
#     actions = ["s3:ListBucket"]
#     resources = ["${local.codedeploy_bucket_arn}/*"]
#   }
#   statement {
#     actions = ["s3:PutObject*"]
#     resources = [local.codedeploy_bucket_arn]
#   }
#   statement {
#     actions   = ["s3:ListAllMyBuckets"]
#     resources = ["*"]
#   }
# }
#
# resource "aws_iam_policy" "codedeploy-app-deploy" {
#   count = local.enable_codedeploy ? 1 : 0
#
#   name        = "${local.codedeploy_name}-codedeploy-app-deploy"
#   description = "Create CodeDeploy revision for app and deploy to app-deploy S3 bucket"
#   policy      = data.aws_iam_policy_document.codedeploy-app-deploy[0].json
# }
#
# resource "aws_iam_role_policy_attachment" "codedeploy-app-deploy" {
#   count = local.enable_codedeploy ? 1 : 0
#
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.codedeploy-app-deploy[0].arn
# }
