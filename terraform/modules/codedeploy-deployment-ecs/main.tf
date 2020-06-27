# Create CodeDeploy deployment group for ECS behind LB

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}-ecs" : var.name
  trigger_name = var.trigger_name == "" ? local.name : var.trigger_name
  deploy_hook = var.deploy_hook == "" ? local.name : var.deploy_hook
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  app_name                = var.codedeploy_app_name
  deployment_group_name   = local.name
  deployment_config_name  = var.deployment_config_name
  service_role_arn        = var.codedeploy_service_role_arn

  dynamic "ecs_service" {
    for_each = var.ecs_service_name == null ? [] : list(1)
    content {
      cluster_name = var.ecs_cluster_name
      service_name = var.ecs_service_name
    }
  }

  # ASG
  dynamic "load_balancer_info" {
    for_each = var.target_group_name == null ? [] : list(1)
    content {
      target_group_info {
        name = var.target_group_name
      }
    }
  }

  # ECS
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-blue-green.html
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-groups-create-load-balancer-for-ecs.html
  dynamic "load_balancer_info" {
    for_each = length(var.target_group_names) > 0 ? list(1) : []
    content {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = var.listener_arns
        }

        dynamic "target_group" {
          for_each = var.target_group_names
          iterator = target_group_name
          content {
            name = target_group_name.value
          }
        }
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

      dynamic "green_fleet_provisioning_option" {
        for_each = var.provisioning_action == null ? [] : list(1)
        content {
          action = var.provisioning_action
        }
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
