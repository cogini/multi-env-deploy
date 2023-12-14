# Security group for app running in private subnet

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "build-app"

  vpc_id = dependency.vpc.outputs.vpc_id
}
