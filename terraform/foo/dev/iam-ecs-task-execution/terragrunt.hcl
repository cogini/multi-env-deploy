# Create ECS IAM Task Execution role

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-ecs-task-execution"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}
