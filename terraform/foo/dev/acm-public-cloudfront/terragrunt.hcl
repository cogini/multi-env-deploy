# Create cert using Amazon Certificate Manager for public domain.

# Cert is for base domain and wildcard.
# Cert for load balancer is created in region where load balancer runs.
# CloudFront certs must be created in us-east-1 region.

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//acm"
}
dependency "route53" {
  config_path = "../route53-public"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  dns_domain = dependency.route53.outputs.name

  # Whether to create Route53 records for validation.
  # Default is true, for primary load balancer cert.
  # False when there is a cert already in another region, e.g. for CloudFront.
  create_route53_records = false

  # Certs for CloudFront must be created in us-east-1
  aws_region = "us-east-1"
}
