# Create IAM instance profile for bastion host

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-instance-profile-app"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "bastion"
}
