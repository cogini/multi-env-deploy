terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-codepipeline"
}
dependency "kms" {
  config_path = "../kms"
}
include {
  path = find_in_parent_folders()
}
inputs = {
  kms_key_id = dependency.kms.outputs.key_id
  codebuild_ecr = true
}
