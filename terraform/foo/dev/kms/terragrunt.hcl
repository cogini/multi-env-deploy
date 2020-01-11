# Create KMS key for app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//kms"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  enable_ec2_as = true
}
