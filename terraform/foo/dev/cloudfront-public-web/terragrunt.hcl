# Create CloudFront distribution for public website

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//cloudfront"
}
dependency "route53" {
  config_path = "../route53-public"
  # config_path = "../route53-cdn" # separate CDN domain
}
dependency "s3" {
  config_path = "../s3-public-web"
}
dependency "s3-logs" {
  config_path = "../s3-request-logs"
}
dependency "lambda" {
  config_path = "../lambda-edge"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  # App name for S3 bucket
  comp = "public-web"

  # DNS hostname, e.g. assets for assets.example.com
  host_name = "www"
  # Add alias for bare domain to distribution
  alias_domain = true
  # Create DNS records for host_name pointing to CloudFront
  create_dns = false

  viewer_protocol_policy = "redirect-to-https"
  lambda_arn = dependency.lambda.outputs.qualified_arn

  origin_bucket_arn = dependency.s3.outputs.buckets["web"].arn
  origin_bucket_id = dependency.s3.outputs.buckets["web"].id
  origin_bucket_domain_name = dependency.s3.outputs.buckets["web"].bucket_regional_domain_name

  logs_bucket_domain_name = dependency.s3-logs.outputs.buckets["logs"].bucket_domain_name

  # DNS zone
  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id
}
