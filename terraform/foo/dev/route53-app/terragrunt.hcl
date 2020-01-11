# Create Route53 records for EC2 instances

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//route53-ec2"
}
dependency "route53" {
  config_path = "../route53-public"
}
dependency "ec2" {
  config_path = "../ec2-app"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  host_name = "app"

  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id

  # EC2 instance(s)
  target_records = dependency.ec2.outputs.public_ip
}
