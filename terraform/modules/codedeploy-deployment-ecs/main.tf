# Create CodeDeploy deployment group for ECS behind LB

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}-ecs" : var.name
  trigger_name = var.trigger_name == "" ? local.name : var.trigger_name
  deploy_hook = var.deploy_hook == "" ? local.name : var.deploy_hook
  deployment_group_name = var.deployment_group_name == "" ? var.name : var.deployment_group_name
}



# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  app_name              = var.codedeploy_app_name
  deployment_group_name = local.deployment_group_name
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = var.deployment_config_name

  ecs_service {
    cluster_name = aws_ecs_cluster.example.name
    service_name = aws_ecs_service.example.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = var.deployment_ready_option_action_on_timeout
      wait_time_in_minutes = var.deployment_ready_option_wait_time_in_minutes
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }

  auto_rollback_configuration {
    enabled = var.auto_rollback_configuration_enabled
    events  = var.auto_rollback_configuration_events
  }

  load_balancer_info {
    target_group_info {
      name = var.target_group_name
    }
  }

  trigger_configuration {
    trigger_name       = local.trigger_name
    trigger_events     = var.trigger_events
    trigger_target_arn = var.trigger_target_arn
  }

  dynamic "alarm_configuration" {
    for_each = var.alarm_configuration
    content {
      alarms                    = lookup(alarm_configuration.value, "alarms", null)
      enabled                   = lookup(alarm_configuration.value, "enabled", null)
      ignore_poll_alarm_failure = lookup(alarm_configuration.value, "ignore_poll_alarm_failure", null)
    }
  }
}
