# Security group for app running in public subnet, normally EC2 instance

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
  comp = "app-public"
  ingress_ports = [22, 80, 443]

  vpc_id = dependency.vpc.outputs.vpc_id
}
