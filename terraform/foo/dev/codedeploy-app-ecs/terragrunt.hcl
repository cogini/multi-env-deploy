# Create CodeDeploy application for app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codedeploy"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  name = "foo-app-ecs"
  compute_platform = "ECS"
}
