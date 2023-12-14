# Security group for prometheus running in public subnet

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
  comp = "prometheus"
  ingress_ports = [22, 80, 443]

  vpc_id = dependency.vpc.outputs.vpc_id
}
