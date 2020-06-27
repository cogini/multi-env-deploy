# Create ECS capacity provider

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/ecs_capacity_provider.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html
resource "aws_ecs_capacity_provider" "this" {
  name = local.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.auto_scaling_group_arn
    managed_termination_protection = var.managed_termination_protection

    dynamic "managed_scaling" {
      for_each = [var.managed_scaling]
      content {
        maximum_scaling_step_size = lookup(managed_scaling.value, "maximum_scaling_step_size", null)
        minimum_scaling_step_size = lookup(managed_scaling.value, "minimum_scaling_step_size", null)
        status                    = lookup(managed_scaling.value, "status", null)
        target_capacity           = lookup(managed_scaling.value, "target_capacity", null)
      }
    }
  }

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags
  )
}
