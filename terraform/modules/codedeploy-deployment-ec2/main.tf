# Create CodeDeploy deployment group for app component to EC2 or on-premises

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}-ec2" : var.name
  trigger_name = var.trigger_name == "" ? local.name : var.trigger_name
}


# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  app_name              = var.codedeploy_app_name
  deployment_group_name = local.name
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = var.deployment_config_name

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  dynamic "ec2_tag_set" {
    for_each = var.ec2_tag_set
    content {
      dynamic "ec2_tag_filter" {
        for_each = lookup(ec2_tag_set.value, "ec2_tag_filter", [])
        content {
          key   = lookup(ec2_tag_filter.value, "key", null)
          type  = lookup(ec2_tag_filter.value, "type", null)
          value = lookup(ec2_tag_filter.value, "value", null)
        }
      }
    }
  }

  dynamic "ec2_tag_filter" {
    iterator = tag_filter
    for_each = var.ec2_tag_filter
    content {
      key   = lookup(tag_filter.value, "key", null)
      type  = lookup(tag_filter.value, "type", null)
      value = lookup(tag_filter.value, "value", null)
    }
  }

  dynamic "on_premises_instance_tag_filter" {
    iterator = tag_filter
    for_each = var.on_premises_instance_tag_filter
    content {
      key   = lookup(tag_filter.value, "key", null)
      type  = lookup(tag_filter.value, "type", null)
      value = lookup(tag_filter.value, "value", null)
    }
  }

  auto_rollback_configuration {
    enabled = var.auto_rollback_configuration_enabled
    events  = var.auto_rollback_configuration_events
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
