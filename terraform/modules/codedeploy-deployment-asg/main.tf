# Create CodeDeploy deployment group for ASG behind LB

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codedeploy-deployment-asg-app"
# }
# dependency "iam" {
#   config_path = "../iam-codepipeline"
# }
# dependency "sns" {
#   config_path = "../sns-codedeploy-app"
# }
# dependency "codedeploy-app" {
#   config_path = "../codedeploy-app"
# }
# dependency "target-group" {
#   config_path = "../target-group-default"
#   # config_path = "../target-group-app"
# }
# dependencies {
#   paths = [
#     "../asg-app"
#   ]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   # Name of component we are deploying
#   comp = "app"
#
#   # Name of deployment group
#   name = "foo-app-asg"
#
#   # Tag to find the ASG
#   deploy_hook = "foo-app"
#
#   target_group_name = dependency.target-group.outputs.name
#
#   # Blue/Green
#   deployment_type   = "BLUE_GREEN"
#   deployment_option = "WITH_TRAFFIC_CONTROL"
#   provisioning_action = "DISCOVER_EXISTING"
#   # provisioning_action = "COPY_AUTO_SCALING_GROUP"
#
#   # In place
#   # deployment_type   = "IN_PLACE"
#   # deployment_option = "WITHOUT_TRAFFIC_CONTROL"
#
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

  autoscaling_groups = var.provisioning_action == "COPY_AUTO_SCALING_GROUP" ? [data.aws_autoscaling_groups.selected.names[0]] : data.aws_autoscaling_groups.selected.names

  dynamic "load_balancer_info" {
    for_each = var.target_group_name == null ? [] : list(1)
    content {
      target_group_info {
        name = var.target_group_name
      }
    }
  }

  deployment_style {
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
  }

  dynamic "blue_green_deployment_config" {
    for_each = var.deployment_type == "BLUE_GREEN" ? list(1) : []
    content {
      deployment_ready_option {
        action_on_timeout    = var.deployment_ready_option_action_on_timeout
        wait_time_in_minutes = var.deployment_ready_option_wait_time_in_minutes
      }

      green_fleet_provisioning_option {
        action = var.provisioning_action
      }

      terminate_blue_instances_on_deployment_success {
        action                           = var.termination_action
        termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
      }
    }
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
