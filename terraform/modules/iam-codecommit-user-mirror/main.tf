# Create IAM user for mirroring git repos into CodeCommit

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-codecommit-user-mirror"
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
  name = var.name == "" ? "${var.org}-${var.app_name}-${var.env}-${var.comp}-mirror" : var.name
}

resource "aws_iam_user" "this" {
  name = local.name
  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags
  )
}

# resource "aws_iam_user_ssh_key" "this" {
#   username   = aws_iam_user.this.name
#   encoding   = "SSH"
#   public_key = var.codecommit_mirror_public_key
# }
