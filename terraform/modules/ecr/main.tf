# Create ECR repository

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# Create repository
# https://www.terraform.io/docs/providers/aws/r/ecr_repository.html
resource "aws_ecr_repository" "this" {
  name = local.name
}

# Give CodeBuild access to repository
resource "aws_ecr_repository_policy" "codebuild" {
  repository = aws_ecr_repository.this.name
  policy     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodeBuildAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOF
}
