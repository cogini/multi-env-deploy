# Security group for load balancer running in public subnet

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
  comp = "lb-public"
  ingress_ports = [80, 443]

  vpc_id = dependency.vpc.outputs.vpc_id
}
