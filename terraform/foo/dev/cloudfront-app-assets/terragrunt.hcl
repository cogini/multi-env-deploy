# Create CloudFront distribution for app assets, e.g. CSS

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//cloudfront"
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
# dependency "lambda" {
#   config_path = "../lambda-edge"
# }
include {
  path = find_in_parent_folders()
}

inputs = {
  # App name for S3 bucket
  comp = "app"

  # DNS hostname, e.g. assets for assets.example.com
  host_name = "assets"

  origin_bucket_arn = dependency.s3.outputs.buckets["assets"].arn
  origin_bucket_id = dependency.s3.outputs.buckets["assets"].id
  origin_bucket_domain_name = dependency.s3.outputs.buckets["assets"].bucket_regional_domain_name

  logs_bucket_domain_name = dependency.s3-logs.outputs.buckets["logs"].bucket_domain_name

  # DNS zone
  dns_domain = dependency.route53.outputs.name
  dns_zone_id = dependency.route53.outputs.zone_id
}
