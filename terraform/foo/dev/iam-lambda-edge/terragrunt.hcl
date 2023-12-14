# Create IAM service role for Lambda@Edge

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-lambda-edge"
}
include "root" {
  path = find_in_parent_folders()
}
