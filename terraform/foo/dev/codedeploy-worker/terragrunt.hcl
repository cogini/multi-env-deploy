# Create CodeDeploy application for worker

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
  comp = "worker"
}
