# Create bucket for logs from load balancer and CloudFront

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-s3-request-logs"
}
dependency "s3" {
  config_path = "../s3-request-logs"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  logs_bucket_arn = dependency.s3.outputs.buckets["logs"].arn
  logs_bucket_id = dependency.s3.outputs.buckets["logs"].id
}
