# Create IAM role with access to CodeCommit repo which can be accessed from
# other AWS accounts

# inputs = {
#   role_arn = dependency.iam-codecomit.outputs.role_arn
# }

# https://docs.aws.amazon.com/codecommit/latest/userguide/cross-account.html

# Create cross role for target
data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.role_arn]
    principals {
      type        = "AWS"
      identifiers = var.repo_target_account_ids
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.app_name}-${var.comp}-codecommit-repo-full-cross"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "this" {
  name        = "${var.app_name}-${var.comp}-codecommit-repo-full-cross"
  description = "Give cross account access to role ${var.app_name}-${var.comp}-codecommit-repo-full"
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
