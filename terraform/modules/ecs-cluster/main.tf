# Create ECS cluster

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//ecs-cluster"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   # name = "foo"
#
#   # capacity_providers = ["FARGATE", "FARGATE_SPOT"]
#   default_capacity_provider_strategy = [
#     {
#         capacity_provider = "FARGATE"
#         weight = 1
#         base = 1
#     },
#     {
#         capacity_provider = "FARGATE_SPOT"
#         weight = 1
#     },
#   ]
#
#   container_insights = "enabled"
#
#   # force_delete = true
# }

locals {
  name = var.name == "" ? "${var.app_name}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create_cluster.html
resource "aws_ecs_cluster" "this" {
  name = local.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy
    content {
      capacity_provider   = lookup(strategy.value, "capacity_provider", null)
      weight              = lookup(strategy.value, "weight", null)
      base                = lookup(strategy.value, "base", null)
    }
  }

  dynamic "setting" {
    for_each = var.container_insights == null ? [] : list(1)
    content {
      name = "containerInsights"
      value = var.container_insights
    }
  }

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags
  )
}
