# Create ASG for "headless" worker instances to handle background jobs.


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

  # List of policies to decide how the instances in the auto scale group should be terminated.
  termination_policies = ["OldestLaunchTemplate", "Default"]

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  # initial_lifecycle_hook

  launch_template {
    id      = var.launch_template_id
    version = "$Latest" # $Latest, or $Default
  }

  vpc_zone_identifier = var.subnets

  # mixed_instances_policy {
  #   launch_template {
  #     launch_template_specification {
  #       id      = var.launch_template_id
  #       version = "$Latest" # $Latest, or $Default
  #     }
  #
  #     override {
  #       instance_type = "c4.large"
  #     }
  #
  #     override {
  #       instance_type = "c3.large"
  #     }
  #   }
  # }

  target_group_arns = var.target_group_arns

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
