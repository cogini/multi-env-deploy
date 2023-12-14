# Configure IAM role allowing GitHub Action to access ECR

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-ecr-github-action"
}
dependency "ecr" {
  config_path = "../ecr-absinthe-app"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name = "absinthe-dev-ecr-github-action-role"
  ecr_arn = dependency.ecr.outputs.arn 
  # repo:<organization>/<repository>:ref:refs/heads/<branch>
  sub = "repo:cogini/*"
}
