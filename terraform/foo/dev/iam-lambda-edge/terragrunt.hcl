# Create IAM service role for Lambda@Edge

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-lambda-edge"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}
