# Create CodeDeploy deployment for headless worker component in ASG

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codedeploy-deployment-asg-worker"
# }
# dependency "iam" {
#   config_path = "../iam-codepipeline"
# }
# dependency "sns" {
#   config_path = "../sns-codedeploy-app"
# }
# dependency "codedeploy-app" {
#   config_path = "../codedeploy-worker"
# }
# dependencies {
#   paths = [
#     "../asg-worker",
#   ]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   # Name of component we are deploying
#   comp = "worker"
#
#   # Name of deployment group
#   name = "foo-worker-asg"
#
#   # Tag to find the ASG
#   deploy_hook = "foo-worker"
#   codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
#   codedeploy_service_role_arn = dependency.iam.outputs.codedeploy_service_role_arn
#
#   # On success, deploy immediately
#   deployment_ready_option_action_on_timeout = "CONTINUE_DEPLOYMENT"
#   deployment_ready_option_wait_time_in_minutes = 0
#
#   # alarm_configuration = {
#   #   alarms  = ["my-alarm-name"]
#   #   enabled = true
#   # }
#
#   trigger_target_arn = dependency.sns.outputs.arn
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}-asg" : var.name
  trigger_name = var.trigger_name == "" ? local.name : var.trigger_name
  deploy_hook = var.deploy_hook == "" ? local.name : var.deploy_hook
}

# Dynamically find the autoscaling group using the "deploy_hook" tag.
# The Blue/Green deployment process makes a copy of the existing
# ASG with a generated unique name, so the name is not stable.
# https://www.terraform.io/docs/providers/aws/d/autoscaling_groups.html
data "aws_autoscaling_groups" "selected" {
  filter {
    name   = "key"
    values = ["deploy_hook"]
  }

  filter {
    name   = "value"
    values = [local.deploy_hook]
  }
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  app_name              = var.codedeploy_app_name
  deployment_group_name = local.name
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = var.deployment_config_name

  autoscaling_groups = [data.aws_autoscaling_groups.selected.names[0]]

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  # Rollback when deployment fails or monitoring threshold is met
  auto_rollback_configuration {
    enabled = var.auto_rollback_configuration_enabled
    events  = var.auto_rollback_configuration_events
  }

  # Stop deployment when CloudWatch alarm detects that a metric has fallen
  # below or exceeded a defined threshold
  dynamic "alarm_configuration" {
    for_each = var.alarm_configuration
    content {
      alarms                    = lookup(alarm_configuration.value, "alarms", null)
      enabled                   = lookup(alarm_configuration.value, "enabled", null)
      ignore_poll_alarm_failure = lookup(alarm_configuration.value, "ignore_poll_alarm_failure", null)
    }
  }

  trigger_configuration {
    trigger_name       = local.trigger_name
    trigger_events     = var.trigger_events
    trigger_target_arn = var.trigger_target_arn
  }
}
