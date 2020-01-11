# Security group for app running in private subnet

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../sg-lb-public",
    "../sg-bastion",
    "../sg-devops",
    "../sg-prometheus",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  app_ports = [80, 443, 4000, 4001]
  app_sources = ["sg-lb-public", "sg-bastion", "sg-devops", "sg-prometheus"]
  ssh_sources = ["sg-bastion"]
  prometheus_sources = ["sg-prometheus"]

  vpc_id = dependency.vpc.outputs.vpc_id
}
