# Create cert using Amazon Certificate Manager for public domain.

# Cert is for the base domain and wildcard.
# Load balancer certs are created in region where load balancer runs.
# CloudFront certs must be created in us-east-1 region.

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//acm"
}
dependency "route53" {
  config_path = "../route53-public"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  dns_domain = dependency.route53.outputs.name_nodot

  # Whether to create Route53 records for validation.
  # Default is true for the primary cert, e.g. for a load balancer.
  # False when there is a cert already in another region, e.g. when creating a
  # cert for CloudFront, which requires the cert to be in us-east-1.
  # create_route53_records = false

  # Override region, certs for CloudFront must be created in us-east-1.
  # aws_region = "us-east-1"
}
