# Give access to CodeDeploy repo

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-codecommit-app"
# }
# dependency "repo" {
#   config_path = "../codecommit-repo-app"
# }
# dependency "user" {
#   config_path = "../iam-codecommit-user-mirror-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   repo_arn = dependency.repo.outputs.arn
#   user_name = dependency.user.outputs.name
# }

# Give full access to repo
data "aws_iam_policy_document" "codecommit-repo-full" {
  statement {
    sid = "AccessCodeCommitRepo"
    actions = [
      "codecommit:BatchGet*",
      "codecommit:Create*",
      "codecommit:DeleteBranch",
      "codecommit:Get*",
      "codecommit:List*",
      "codecommit:Describe*",
      "codecommit:Put*",
      "codecommit:Post*",
      "codecommit:Merge*",
      "codecommit:Test*",
      "codecommit:Update*",
      "codecommit:GitPull",
      "codecommit:GitPush",
    ]
    resources = [var.repo_arn]
  }
}

resource "aws_iam_policy" "codecommit-repo-full" {
  name   = "${var.app_name}-${var.comp}-codecommit-repo-full"
  policy = data.aws_iam_policy_document.codecommit-repo-full.json
}

# Give mirror user access to repo
resource "aws_iam_user_policy_attachment" "codecommit-repo-full" {
  user       = var.user_name
  policy_arn = aws_iam_policy.codecommit-repo-full.arn
}

# Create role with access to repo, used by cross account access
# https://docs.aws.amazon.com/codecommit/latest/userguide/cross-account.html
resource "aws_iam_role" "this" {
  name               = "${var.app_name}-${var.comp}-codecommit-repo-full"
  description        = "Give access to codecommit repo ${var.app_name}-${var.comp}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Give role access to repo
resource "aws_iam_role_policy_attachment" "codecommit-repo-full" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.codecommit-repo-full.arn
}

# data "aws_iam_policy" "codecommit" {
#   arn = "arn:${var.aws_partition}:iam::aws:policy/AWSCodeCommitFullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "codecommit" {
#   user       = aws_iam_user.mirror.name
#   policy_arn = data.aws_iam_policy.codecommit.arn
# }
