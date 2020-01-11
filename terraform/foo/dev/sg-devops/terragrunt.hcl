# Security group for devops running in private subnet

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../sg-bastion",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "devops"
  ssh_sources = ["sg-bastion"]

  vpc_id = dependency.vpc.outputs.vpc_id
}
