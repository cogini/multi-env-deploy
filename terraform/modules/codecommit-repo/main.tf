# Create a CodeCommit repository

# Example config:
#
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codecommit-repo-app"
# }
# dependencies {
#   paths = []
# }
# include {
#   path = find_in_parent_folders()
# }
#
# imputs = {
#   comp = "app"
#   repository_name = "foo"
# }

locals {
  repository_name = var.repository_name != "" ? var.repository_name : "${var.org}-${var.app_name}-${var.comp}"
}

resource "aws_codecommit_repository" "this" {
  repository_name = local.repository_name

  # description = var.repository_description
  default_branch = var.repository_default_branch
}
