# Create ASG for "headless" worker instances to handle background jobs.

# Example config
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//asg-worker"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "lt" {
#   config_path = "../launch-template-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "worker"
#
#   min_size = 1
#   max_size = 3
#   desired_capacity = 1
#   wait_for_capacity_timeout = "2m"
#
#   health_check_grace_period = 30
#   health_check_type = "EC2"
#
#   subnets = dependency.vpc.outputs.subnets["private"]
#
#   launch_template_id = dependency.lt.outputs.launch_template_id
#   launch_template_version = "$Latest" # $Latest, or $Default
#   # spot_max_price = ""
#
#   force_delete = true
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  deploy_hook = var.deploy_hook == "" ? local.name : var.deploy_hook
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "this" {
  name_prefix = "${local.name}-"

  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  # min_elb_capacity          = var.min_elb_capacity
  # wait_for_elb_capacity     = var.wait_for_elb_capacity

  default_cooldown          = var.default_cooldown

  termination_policies      = var.termination_policies

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  # initial_lifecycle_hook

  dynamic "launch_template" {
    for_each = var.spot_max_price == null ? list(1) : []
    content {
      id      = var.launch_template_id
      version = "$Latest" # $Latest, or $Default
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.spot_max_price == null ? [] : list(1)
    content {
      instances_distribution {
        on_demand_allocation_strategy = var.on_demand_allocation_strategy
        on_demand_base_capacity = var.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
        spot_allocation_strategy = var.spot_allocation_strategy
        spot_instance_pools = var.spot_instance_pools
        spot_max_price = var.spot_max_price
      }

      launch_template {
        launch_template_specification {
          launch_template_id = var.launch_template_id
          version = var.launch_template_version
        }

        dynamic "override" {
          for_each = var.override_instance_types
          content {
            instance_type = override.value
            # weighted_capacity
          }
        }
      }
    }
  }

  # target_group_arns = var.target_group_arns

  vpc_zone_identifier = var.subnets

  # suspended_processes

  tags = concat(
    [
      {
        "key"                 = "deploy_hook"
        "value"               = local.deploy_hook
        "propagate_at_launch" = false
      },
      # These normally come from the launch template
      {
        "key"                 = "Name"
        "value"               = local.name
        # Override EC2 instance name to match ASG
        "propagate_at_launch" = true
      },
      {
        "key"                 = "comp"
        "value"               = var.comp
        "propagate_at_launch" = false
      },
      {
        "key"                 = "org"
        "value"               = var.org
        "propagate_at_launch" = false
      },
      {
        "key"                 = "app"
        "value"               = var.app_name
        "propagate_at_launch" = false
      },
      {
        "key"                 = "env"
        "value"               = var.env
        "propagate_at_launch" = false
      },
      {
        "key"                 = "owner"
        "value"               = var.owner
        "propagate_at_launch" = false
      },
    ],
    var.extra_tags_list,
  )

  # placement_group

  # metrics_granularity = var.metrics_granularity
  enabled_metrics = var.enabled_metrics

  # protect_from_scale_in
  # service_linked_role_arn

  force_delete = var.force_delete

  lifecycle {
    create_before_destroy = true
  }
}
