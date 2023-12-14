# Define IAM service role for CodePipeline

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-codepipeline"
}
dependency "kms" {
  config_path = "../kms"
}
include "root" {
  path = find_in_parent_folders()
}
inputs = {
  kms_key_id = dependency.kms.outputs.key_id
  codebuild_ecr = true
}
