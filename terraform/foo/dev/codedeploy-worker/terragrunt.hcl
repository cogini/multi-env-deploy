# Create CodeDeploy application for worker

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//codedeploy"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
}
