# Create Load Balancer in public subnet

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//lb"
}
dependency "route53" {
  config_path = "../route53-public"
}
dependency "s3" {
  config_path = "../s3-request-logs"
}
dependency "sg" {
  config_path = "../sg-lb-public"
}
dependency "tg" {
  config_path = "../target-group-default"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../acm-public",
  ]
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "public"
  name = "foo" # legacy

  access_logs_bucket_id = dependency.s3.outputs.buckets["logs"].id
  subnet_ids = dependency.vpc.outputs.subnets["public"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  target_group_arn = dependency.tg.outputs.arn
  dns_domain = dependency.route53.outputs.name
}
