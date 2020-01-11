# Create SNS topic for component

# Example config:
#
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//sns"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   comp = "codedeploy-app"
# }

locals {
  name = var.name == "" ? "${var.org}-${var.app_name}-${var.env}-${var.comp}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/sns_topic.html
resource "aws_sns_topic" "this" {
  name = local.name
}
