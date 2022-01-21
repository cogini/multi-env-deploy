# Create IAM role for a GitHub Action to run CodeBuild on a project
#
# https://github.com/aws-actions/aws-codebuild-run-build
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://scalesec.com/blog/identity-federation-for-github-actions-on-aws/

data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  name        = var.name == "" ? "${var.app_name}-${var.env}" : var.name
}

resource "aws_iam_role" "this" {
  name = local.name
  description = "Allow GitHub Action to run CodeBuild"
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
    # Version = "2012-10-17",
    # Statement = [{
    #   Action = "sts:AssumeRoleWithWebIdentity"
    #   Effect = "Allow"
    #   Principal = {
    #     Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
    #   }
    #   Condition = {
    #     StringLike = {
    #       # "token.actions.githubusercontent.com:aud" :  ["sts.amazonaws.com" ],
    #       "token.actions.githubusercontent.com:sub" : var.sub
    #     }
    #   }
    # }]
  # })
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
