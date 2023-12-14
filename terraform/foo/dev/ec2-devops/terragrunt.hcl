# Create app EC2 instance

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//ec2-private"
}
dependency "iam" {
  config_path = "../iam-instance-profile-devops"
}
dependency "sg" {
  config_path = "../sg-devops"
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
  comp = "devops"

  # Single instance
  instance_count = 1

  instance_type = "t3.micro"

  # Ubuntu 18.04
  # ami = "ami-0f63c02167ca94956"

  # Increase root volume size, necessary when building large apps
  # root_volume_size = 400

  subnet_ids = dependency.vpc.outputs.subnets["public"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name

  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id
}
