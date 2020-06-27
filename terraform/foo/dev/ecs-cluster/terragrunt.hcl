# Create ECS cluster

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ecs-cluster"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  # name = "foo" # Default is app_name

  # capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [
    {
        capacity_provider = "FARGATE"
        weight = 1
        base = 1
    },
    {
        capacity_provider = "FARGATE_SPOT"
        weight = 1
    },
  ]

  container_insights = "enabled"

  # force_delete = true
}
