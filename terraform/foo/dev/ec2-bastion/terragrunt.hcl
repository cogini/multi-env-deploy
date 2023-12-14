# Create bastion EC2 instance

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//ec2-public"
}
dependency "iam" {
  config_path = "../iam-instance-profile-bastion"
}
dependency "sg" {
  config_path = "../sg-bastion"
}
dependency "route53" {
  config_path = "../route53-public"
}
dependency "vpc" {
  config_path = "../vpc"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "bastion"

  # keypair_name = "bergey-dev"

  dns_health_check = true

  # Create one per az
  # instance_count = 0

  # Single instance
  instance_count = 1

  instance_type = "t3.nano"

  # Ubuntu 18.04
  # ami = "ami-0f63c02167ca94956"

  subnet_ids = dependency.vpc.outputs.subnets["public"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name

  create_dns = true
  dns_domain = dependency.route53.outputs.name_nodot
  dns_zone_id = dependency.route53.outputs.zone_id
}
