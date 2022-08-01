# Create IAM role for a GitHub Action to access ECR
#
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://scalesec.com/blog/identity-federation-for-github-actions-on-aws/

data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  name        = var.name == "" ? "${var.app_name}-${var.env}" : var.name
}

resource "aws_iam_role" "this" {
  name = local.name
  description = "Allow GitHub Action to access ECR"
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

# Add permissions to access ECR
data "aws_iam_policy_document" "ecr" {
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
  name_prefix = "${var.app_name}-github-action-ecr"
  description = "Allow GitHub Action to access ECR"
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy_attachment" "github-action-ecr" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr.arn
}
