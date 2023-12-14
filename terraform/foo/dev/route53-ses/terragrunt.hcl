# Create Route53 records to validate email sending via SES

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//route53-ses"
}
dependency "route53" {
  config_path = "../route53-public"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # Domain used for sending mail, verified with SES
  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id

  aws_region = "us-east-1"
}
