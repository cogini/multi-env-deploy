# Create IAM group with cross account access to CodeCommit repo

# https://docs.aws.amazon.com/codecommit/latest/userguide/cross-account.html

resource "aws_iam_group" "this" {
  name = "${var.app_name}-${var.comp}-codecommit-repo-full"
}

# Create cross role for target
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:${var.aws_partition}:iam::${var.repo_source_account_id}:role/${var.app_name}-${var.comp}-codecommit-repo-full-cross",
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.app_name}-${var.comp}-codecommit-repo-full-cross-target"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.this.arn
}
