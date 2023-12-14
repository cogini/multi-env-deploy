terraform {
  source = "${dirname(find_in_parent_folders())}/modules//ec2-public"
}
dependency "iam" {
  config_path = "../iam-instance-profile-prometheus"
}
dependency "sg" {
  config_path = "../sg-prometheus"
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
  comp = "prometheus"


  # Single instance
  instance_count = 1

  instance_type = "t3.micro"

  # Ubuntu 18.04
  # ami = "ami-0f63c02167ca94956"

  subnet_ids = dependency.vpc.outputs.subnets["public"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name

  create_dns = true
  dns_health_check = true
  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id
}
