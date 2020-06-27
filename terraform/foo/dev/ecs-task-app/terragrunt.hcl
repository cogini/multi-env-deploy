# Create ECS service

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ecs-task"
}
dependency "iam-task" {
  config_path = "../iam-ecs-task-role-app"
}
dependency "iam-execution" {
  config_path = "../iam-ecs-task-execution"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#specify-log-config
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_AWSCLI_Fargate.html
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html
  container_definitions = file("${get_terragrunt_dir()}/container_definitions.json")

  # container_definitions = <<DEFINITION
# [
  # {
  #   "name": "${var.container_name}",
  #   "image": "hello-world",
  #   "essential": true,
  #   "portMappings": [],
  #   "environment": [],
  #   "logConfiguration": {
  #     "logDriver": "awslogs",
  #     "options": {
  #       "awslogs-group": "${local.log_group}",
  #       "awslogs-region": "us-east-1",
  #       "awslogs-stream-prefix": "fargate"
  #     }
  #   }
  # }
# ]
# DEFINITION

  task_role_arn = dependency.iam-task.outputs.arn
  execution_role_arn = dependency.iam-execution.outputs.arn

  # FARGATE supported values
  # CPU value       Memory value (MiB)
  # 256 (.25 vCPU)  512 (0.5 GB), 1024 (1 GB), 2048 (2 GB)
  # 512 (.5 vCPU)   1024 (1 GB), 2048 (2 GB), 3072 (3 GB), 4096 (4 GB)
  # 1024 (1 vCPU)   2048 (2 GB), 3072 (3 GB), 4096 (4 GB), 5120 (5 GB), 6144 (6 GB), 7168 (7 GB), 8192 (8 GB)
  # 2048 (2 vCPU)   Between 4096 (4 GB) and 16384 (16 GB) in increments of 1024 (1 GB)
  # 4096 (4 vCPU)   Between 8192 (8 GB) and 30720 (30 GB) in increments of 1024 (1 GB)
  cpu = 256
  memory = 512

  # force_delete = true
}
