# Create CloudFront distribution for app assets, e.g. CSS

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//cloudfront"
}
dependency "route53" {
  config_path = "../route53-public"
  # config_path = "../route53-cdn" # separate CDN domain
}
dependency "s3" {
  config_path = "../s3-app"
}
dependency "s3-logs" {
  config_path = "../s3-request-logs"
}
# Use lambda for public static website
# dependency "lambda" {
#   config_path = "../lambda-edge"
# }
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # App name for S3 bucket
  comp = "app"

  # DNS hostname
  # Use "www" for public static website, "assets" for assets.example.com
  host_name = "assets"

  # Create DNS records for host_name pointing to CloudFront
  # Set to true for public static site, false for the app
  create_dns = false

  # Add alias for bare domain to CloudFront distribution
  # Set to true for public static site
  alias_domain = false

  # Redirect HTTP to HTTPS
  # viewer_protocol_policy = "redirect-to-https"

  # lambda_arn = dependency.lambda.outputs.qualified_arn

  origin_bucket_arn = dependency.s3.outputs.buckets["assets"].arn
  origin_bucket_id = dependency.s3.outputs.buckets["assets"].id
  origin_bucket_domain_name = dependency.s3.outputs.buckets["assets"].bucket_regional_domain_name

  logs_bucket_domain_name = dependency.s3-logs.outputs.buckets["logs"].bucket_domain_name

  # DNS zone
  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id
}
