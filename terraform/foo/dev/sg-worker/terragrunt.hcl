# Security group for worker running in private subnet

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../sg-bastion",
    "../sg-devops",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
  ssh_sources = ["sg-bastion", "sg-devops"]

  vpc_id = dependency.vpc.outputs.vpc_id
}
