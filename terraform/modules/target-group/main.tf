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
#   port = 4001
#   protocol = "HTTPS"
#
#   health_check = {
#     path = "/"
#     interval = 30
#     timeout = 10
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#     matcher = "200"
#   }
#
#   # stickiness = {
#   #   type = "lb_cookie"
#   # }
#
#   listener_arn = dependency.lb.outputs.listener_arn
#   vpc_id = dependency.vpc.outputs.vpc_id
# }

locals {
  name  = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  hosts = length(var.hosts) == 0 ? ["${var.host_name}.${replace(var.zone_name, "/\\.$/", "")}"] : var.hosts
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html
resource "aws_lb_target_group" "this" {
  name        = local.name
  port        = var.port
  protocol    = var.protocol

  dynamic "health_check" {
    for_each = [var.health_check]
    content {
      enabled             = lookup(health_check.value, "enabled", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      interval            = lookup(health_check.value, "interval", null)
      matcher             = lookup(health_check.value, "matcher", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
    }
  }

  dynamic "stickiness" {
    for_each = [var.stickiness]
    content {
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      enabled         = lookup(stickiness.value, "enabled", null)
      type            = stickiness.value.type
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
  listener_arn = var.listner_arn

  # priority = var.priority

  action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = local.hosts
  }

  condition {
    field  = "path-pattern"
    values = var.paths
  }
}
