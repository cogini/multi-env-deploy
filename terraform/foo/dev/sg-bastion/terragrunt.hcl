# Security group for bastion host running in public subnet,

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
  comp = "bastion"
  ingress_ports = [22]

  vpc_id = dependency.vpc.outputs.vpc_id
}
