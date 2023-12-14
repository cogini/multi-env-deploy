# Security group for devops running in private subnet

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../sg-bastion",
  ]
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "devops"
  ssh_sources = ["sg-bastion"]

  vpc_id = dependency.vpc.outputs.vpc_id
}
