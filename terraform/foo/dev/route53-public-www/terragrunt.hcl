# Create alias for base domain and www to Load Balancer or CloudFront

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//route53-alias"
}
dependency "route53" {
  config_path = "../route53-public"
}
dependency "lb" {
  config_path = "../lb-public"
}
# dependency "cloudfront" {
#   config_path = "../cloudfront-public-web"
# }
# dependency "s3" {
#   config_path = "../s3-app"
# }
include {
  path = find_in_parent_folders()
}

inputs = {
  # Name of host part, e.g. www for www.example.com
  host_name = "www"

  # Whether to create alias for the domain, e.g. example.com
  alias_domain = true

  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id

  # LB
  target_name = dependency.lb.outputs.dns_name
  target_zone_id = dependency.lb.outputs.zone_id

  # CloudFront
  # target_name = dependency.cloudfront.outputs.domain_name
  # target_name = dependency.cloudfront.outputs.hosted_zone_id

  # S3 bucket
  # target_name = dependency.s3.outputs.buckets["protected_web"].website_endpoint
  # target_zone_id = dependency.s3.outputs.buckets["protected_web"].hosted_zone_id
}
