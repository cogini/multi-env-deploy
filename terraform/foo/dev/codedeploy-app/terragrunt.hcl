# Create CodeDeploy application for app

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//codedeploy"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
}
