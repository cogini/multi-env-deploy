# Create CodeDeploy deployment group for app component to EC2 or on-premises

locals {
  name         = var.name == "" ? "${var.app_name}-${var.comp}-ec2" : var.name
  trigger_name = var.trigger_name == "" ? local.name : var.trigger_name
}


# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html
resource "aws_codedeploy_deployment_group" "this" {
  app_name               = var.codedeploy_app_name
  deployment_group_name  = local.name
  deployment_config_name = var.deployment_config_name
  service_role_arn       = var.codedeploy_service_role_arn

  # https://docs.aws.amazon.com/codedeploy/latest/userguide/instances-tagging.html
  # The Terraform names are confusing. Filters are "OR" and Sets are "AND".

  dynamic "ec2_tag_filter" {
    iterator = tag_filter
    for_each = var.ec2_tag_filter
    content {
      key   = lookup(tag_filter.value, "key", null)
      type  = lookup(tag_filter.value, "type", null)
      value = lookup(tag_filter.value, "value", null)
    }
  }

  dynamic "ec2_tag_set" {
    for_each = var.ec2_tag_set
    iterator = tag_set
    content {
      dynamic "ec2_tag_filter" {
        for_each = tag_set.value
        iterator = tag_filter
        content {
          key   = lookup(tag_filter.value, "key", null)
          type  = lookup(tag_filter.value, "type", null)
          value = lookup(tag_filter.value, "value", null)
        }
      }
    }
  }

  deployment_style {
    deployment_option = var.deployment_option
    deployment_type   = var.deployment_type
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

  # Not supported by Terraform :-/
  # dynamic "on_premises_tag_set" {
  #   for_each = (length(var.on_premises_tag_set) > 0) ? [var.on_premises_tag_set] : []
  #   content {
  #     dynamic "on_premises_instance_tag_filter" {
  #       for_each = var.on_premises_instance_tag_set
  #       iterator = tag_filter
  #       content {
  #         key   = lookup(tag_filter.value, "key", null)
  #         type  = lookup(tag_filter.value, "type", null)
  #         value = lookup(tag_filter.value, "value", null)
  #       }
  #     }
  #   }
  # }

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
