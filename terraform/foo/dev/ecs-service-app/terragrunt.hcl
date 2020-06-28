# Create ECS service

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ecs-service"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "sg" {
  config_path = "../sg-app-private"
}
dependency "tg" {
  config_path = "../target-group-app-ecs-1"
}
# dependency "iam" {
#   config_path = "../iam-instance-profile-app"
# }
dependency "cluster" {
  config_path = "../ecs-cluster"
}
dependency "task" {
  config_path = "../ecs-task-app"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  cluster = dependency.cluster.outputs.arn
  task_definition = dependency.task.outputs.arn

  load_balancer = [
    {
      target_group_arn = dependency.tg.outputs.arn
      container_name = "foo-app"
      container_port = 4000
    }
  ]

  # launch_type = "EC2" # default "FARGATE"

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight = 1
      base = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight = 1
    }
  ]

  deployment_controller_type = "CODE_DEPLOY"

  # deployment_maximum_percent = 200
  # deployment_minimum_healthy_percent = 0
  desired_count = 1
  # health_check_grace_period_seconds = 30

  # iam_role = dependency.iam.outputs.instance_profile_name

  network_configuration = {
    subnets = dependency.vpc.outputs.subnets["private"]
    security_groups = [dependency.sg.outputs.security_group_id]
    assign_public_ip = false # true when running in public subnet
  }

  enable_ecs_managed_tags = true

  # propagate_tags = "SERVICE" | "TASK_DEFINITION"

  # ordered_placement_strategy = [
  #   {
  #     type  = "binpack"
  #     field = "cpu"
  #   }
  # ]

  # placement_constraints = [
  #   {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }
  # ]

  # force_delete = true
}
