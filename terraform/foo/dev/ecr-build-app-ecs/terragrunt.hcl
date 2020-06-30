terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ecr-build"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  name = "foo-app-ecs-build"
}
