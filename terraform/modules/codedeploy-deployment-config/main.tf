# Create CodeDeploy deployment config

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_config.html
resource "aws_codedeploy_deployment_config" "this" {
  deployment_config_name = local.name
  compute_platform       = var.compute_platform

  minimum_healthy_hosts = {
    type  = var.minimum_healthy_hosts_type
    value = var.minimum_healthy_hosts_value
  }
}
