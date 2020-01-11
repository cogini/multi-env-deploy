# Create CodeDeploy app for component

resource "aws_codedeploy_app" "this" {
  compute_platform = var.compute_platform
  name             = "${var.app_name}-${var.comp}"
}
