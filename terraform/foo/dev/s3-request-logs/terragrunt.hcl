# Create bucket for AWS request logs from load balancer and CloudFront

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//s3-app"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "request"

  # Force S3 buckets to be deleted even when they are not empty
  # This is useful in dev, but dangerous in prod
  force_destroy = true

  buckets = {
    # Request logs from load balancer and CloudFront
    logs = {
        encrypt = false
    }
  }
}
