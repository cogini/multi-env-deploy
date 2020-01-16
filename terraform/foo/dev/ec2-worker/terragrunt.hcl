terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ec2-private"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "iam" {
  config_path = "../iam-instance-profile-worker"
}
dependency "sg" {
  config_path = "../sg-worker"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
  name = "foo-worker-ec2"

  instance_type = "t3.nano"

  extra_tags = {
    deploy_hook = "foo-worker-ec2"
  }

  # Create a single instance
  instance_count = 1

  ami = "ami-0d2c61276077f361c"

  # Ubuntu 18.04
  # ami = "ami-0f63c02167ca94956"

  # CentOS 7
  # ami = "ami-8e8847f1"

  # Amazon Linux 2
  # ami = "ami-0d7ed3ddb85b521a6"

  subnet_ids = dependency.vpc.outputs.subnets["private"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name

  dns_domain = dependency.vpc.outputs.private_dns_domain
  dns_zone_id = dependency.vpc.outputs.private_dns_zone_id
}
