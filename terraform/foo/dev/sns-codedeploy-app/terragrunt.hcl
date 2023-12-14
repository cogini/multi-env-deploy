# Create SNS topic

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//sns"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "codedeploy"
  name = "foo-dev-codedeploy"
}
