terraform {
  source = "${get_terragrunt_dir()}/../../../modules//lambda-edge"
}
dependency "iam" {
  config_path = "../iam-lambda-edge"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  service_role_arn = dependency.iam.outputs.service_role_arn
}
