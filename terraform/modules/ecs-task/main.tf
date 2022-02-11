# Create ECS task definition
data "aws_caller_identity" "current" {}

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  ssm_ps_arn = "arn:${var.aws_partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter"
  ssm_ps_param_prefix = var.ssm_ps_param_prefix == "" ? "${var.org}/${var.app_name}/${var.env}/${var.comp}" : var.ssm_ps_param_prefix
  ssm_ps_arn_param_prefix = "${local.ssm_ps_arn}/${local.ssm_ps_param_prefix}"
  secrets = [for s in var.secrets: merge(s, {valueFrom = "${local.ssm_ps_arn_param_prefix}/${s["valueFrom"]}"})]
}

# Generate JSON continer config from vars
module "app_container" {
  source = "github.com/cloudposse/terraform-aws-ecs-container-definition?ref=0.58.1"

  container_name = local.name
  container_image = var.image
  container_memory = var.container_memory
  container_memory_reservation = var.memory_reservation
  container_cpu = var.container_cpu

  port_mappings = var.port_mappings

  environment = var.environment
  secrets = local.secrets

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group" = "/ecs/${local.name}"
      "awslogs-region" = var.aws_region
      "awslogs-stream-prefix" = local.name
      "awslogs-create-group" = var.cloudwatch_logs_create_group
    }
    secretOptions = []
  }
}

module "xray_container" {
  source = "github.com/cloudposse/terraform-aws-ecs-container-definition?ref=0.58.1"

  container_name = "xray-daemon"
  container_image = var.xray_image
  container_memory_reservation = 256
  # container_cpu = 32
  container_cpu = 0
  essential = false

  port_mappings = [
    {
      containerPort = 2000
      hostPort      = 2000
      protocol      = "udp"
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group" = "/ecs/${local.name}"
      "awslogs-region" = var.aws_region
      "awslogs-stream-prefix" = local.name
      "awslogs-create-group" = var.cloudwatch_logs_create_group
    }
    secretOptions = []
  }
}


# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
resource "aws_ecs_task_definition" "this" {
  family = local.name

  container_definitions = <<-EOT
  [
    ${module.app_container.json_map_encoded}
    ${var.xray ? ", ${module.xray_container.json_map_encoded}" : ""}
  ]
  EOT

  task_role_arn = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  cpu = var.cpu
  memory = var.memory
  requires_compatibilities = var.requires_compatibilities

  network_mode = var.network_mode
  ipc_mode = var.ipc_mode
  pid_mode = var.pid_mode

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html
  dynamic "volume" {
    for_each = var.volume
    content {
      name      = lookup(volume.value, "name", null)
      host_path = lookup(volume.value, "host_path", null)

      # https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#docker-volume-configuration-arguments
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-volumes.html#specify-volume-config
      # EC2 launch type only
      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", [])
        content {
          scope         = lookup(docker_volume_configuration.value, "scope", null) # "task" | "shared"
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null) # bool
          driver        = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts   = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels        = lookup(docker_volume_configuration.value, "labels", null)
        }
      }

      # # https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#efs-volume-configuration-arguments
      # # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_efs.html
      # # EC2 launch type only
      # dynamic "efs_volume_configuration" {
      #   for_each = lookup(volume.value, "efs_volume_configuration", [])
      #   content {
      #     filesystem_id = lookup(efs_volume_configuration.value, "filesystem_id", null)
      #     root_directory = lookup(efs_volume_configuration.value, "root_directory", null)
      #   }
      # }
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type        = lookup(placement_constraints.value, "type", null)
      expression  = lookup(placement_constraints.value, "expression", {})
    }
  }

  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration == null ? [] : tolist([1])
    content {
      type            = lookup(proxy_configuration.value, "type", null)
      container_name  = lookup(proxy_configuration.value, "container_name", null)
      properties      = lookup(proxy_configuration.value, "properties", null)
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
