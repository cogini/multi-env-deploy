# Security group for app running in private subnet

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "build-worker"

  vpc_id = dependency.vpc.outputs.vpc_id
}
