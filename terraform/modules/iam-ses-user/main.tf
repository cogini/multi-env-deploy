# Create IAM user with rights to send email via SES
#
# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html
# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/postfix.html#send-email-postfix

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-ses-user"
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
# }

locals {
  name = var.name == "" ? "${var.org}-${var.app_name}-${var.comp}-${var.env}-ses" : var.name
}

resource "aws_iam_user" "this" {
  name = local.name
  tags = merge(
    {
      "Name" = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags
  )
}

resource "aws_iam_user_policy" "this" {
  user   = aws_iam_user.this.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ses:SendRawEmail",
            "Resource": "*"
        }
    ]
}
EOF
}

# THIS IS NOT SECURE, the user id and password are in the Terraform output.
# Instead generate key via the console and copy the id and key into the
# Ansible vault

# resource "aws_iam_access_key" "this" {
#   user = aws_iam_user.this.name
# }
