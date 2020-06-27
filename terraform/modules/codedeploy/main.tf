# Create CodeDeploy app for component

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_app.html
resource "aws_codedeploy_app" "this" {
  name             = local.name
  compute_platform = var.compute_platform
}
