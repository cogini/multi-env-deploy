# Create IAM instance profile for bastion host

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-instance-profile-app"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "bastion"
}
