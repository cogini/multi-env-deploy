# Create KMS key for app

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//kms"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # Allow AWS service linked role for EC2 auto scaling to mount encrypted EBS volumes
  enable_ec2_as = true
}
