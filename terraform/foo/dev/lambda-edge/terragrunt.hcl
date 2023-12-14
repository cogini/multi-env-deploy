terraform {
  source = "${dirname(find_in_parent_folders())}/modules//lambda-edge"
}
dependency "iam" {
  config_path = "../iam-lambda-edge"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  service_role_arn = dependency.iam.outputs.service_role_arn
}
