# Create IAM role for a GitHub Action to run CodeBuild on a project
#
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://scalesec.com/blog/identity-federation-for-github-actions-on-aws/
# https://github.com/aws-actions/aws-codebuild-run-build

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  name       = var.name == "" ? "${var.app_name}-${var.env}" : var.name
}

resource "aws_iam_role" "this" {
  name               = local.name
  description        = "Allow GitHub Action to call AWS services"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "${var.sub}"
        }
      }
    }
  ]
}
EOF
}

# Add permissions to run CodeBuild and get resulting log messages
data "aws_iam_policy_document" "codebuild-project" {
  statement {
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = ["arn:aws:codebuild:${var.aws_region}:${local.account_id}:project/${var.codebuild_project_name}"]
  }

  statement {
    actions   = ["logs:GetLogEvents"]
    resources = ["arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/codebuild/${var.codebuild_project_name}:*"]
  }
}

resource "aws_iam_policy" "codebuild-project" {
  name_prefix = "${var.app_name}-codebuild-project"
  description = "Allow GitHub Action to run CodeBuild"
  policy      = data.aws_iam_policy_document.codebuild-project.json
}

resource "aws_iam_role_policy_attachment" "github-action" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.codebuild-project.arn
}

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

resource "aws_iam_role_policy_attachment" "codedeploy-app-deploy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.codedeploy-app-deploy.arn
}
