terraform {
  source = "${dirname(find_in_parent_folders())}/modules//ec2-private"
}
dependency "iam" {
  config_path = "../iam-instance-profile-worker"
}
dependency "sg" {
  config_path = "../sg-worker"
}
dependency "vpc" {
  config_path = "../vpc"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
  name = "foo-worker-ec2"

  extra_tags = {
    deploy_hook = "foo-worker-ec2"
  }

  # Single instance
  instance_count = 1

  instance_type = "t3.nano"

  # Ubuntu 18.04
  # ami = "ami-0f63c02167ca94956"

  subnet_ids = dependency.vpc.outputs.subnets["private"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name

  dns_domain = dependency.vpc.outputs.private_dns_domain
  dns_zone_id = dependency.vpc.outputs.private_dns_zone_id
}
