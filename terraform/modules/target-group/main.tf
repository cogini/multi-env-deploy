# Create a load balancer target group for app

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//target-group"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "lb" {
#   config_path = "../lb-public"
# }
# dependency "zone" {
#   config_path = "../route53-public"
#   # config_path = "../route53-cdn" # separate CDN domain
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   host_name = "app"
#
#   port = 4001
#   protocol = "HTTPS"
#
#   health_check = {
#     path = "/"
#     # interval = 30 # default 30
#     # timeout = 10 # default 5
#     healthy_threshold = 2 # default 3
#     unhealthy_threshold = 2 # default 3
#     matcher = 200
#   }
#
#   # stickiness = {
#   #   type = "lb_cookie"
#   # }
#
#   listener_arn = dependency.lb.outputs.listener_arn
#   vpc_id = dependency.vpc.outputs.vpc_id
#   zone_name = dependency.zone.outputs.name
# }

locals {
  name  = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  hosts = [for host in var.hosts : replace(host, "/\\.$/", "")]
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html
resource "aws_lb_target_group" "this" {
  name                 = local.name
  port                 = var.port
  protocol             = var.protocol
  deregistration_delay = var.deregistration_delay

  dynamic "health_check" {
    for_each = var.health_check == null ? [] : tolist([1])
    content {
      enabled             = lookup(var.health_check, "enabled", null)
      healthy_threshold   = lookup(var.health_check, "healthy_threshold", null)
      interval            = lookup(var.health_check, "interval", null)
      matcher             = lookup(var.health_check, "matcher", null)
      path                = lookup(var.health_check, "path", null)
      port                = lookup(var.health_check, "port", null)
      protocol            = lookup(var.health_check, "protocol", null)
      timeout             = lookup(var.health_check, "timeout", null)
      unhealthy_threshold = lookup(var.health_check, "unhealthy_threshold", null)
    }
  }

  # slow_start

  dynamic "stickiness" {
    for_each = var.stickiness == null ? [] : tolist([1])
    content {
      cookie_duration = lookup(var.stickiness, "cookie_duration", null)
      enabled         = lookup(var.stickiness, "enabled", null)
      type            = lookup(var.stickiness, "type", "lb_cookie")
    }
  }

  vpc_id      = var.vpc_id
  target_type = var.target_type

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html
resource "aws_lb_listener_rule" "this" {
  count        = var.listener_rule ? 1 : 0
  listener_arn = var.listener_arn

  priority = var.priority

  action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

  dynamic "condition" {
    for_each = length(local.hosts) > 0 ? tolist([1]) : []
    content {
      host_header {
        values = local.hosts
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.paths) > 0 ? tolist([1]) : []
    content {
      path_pattern {
        values = var.paths
      }
    }
  }
}
