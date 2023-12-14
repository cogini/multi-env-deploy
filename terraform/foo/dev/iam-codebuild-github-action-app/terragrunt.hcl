# Configure IAM role allowing GitHub Action to run CodeBuild project

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-codebuild-github-action"
}
dependency "codebuild" {
  config_path = "../codebuild-github-action"
}
# dependencies {
#   paths = [
#   ]
# }
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name = "foo-dev-codebuild-github-action-role"
  codebuild_project_name = dependency.codebuild.outputs.codebuild_project_name 
  # repo:<organization>/<repository>:ref:refs/heads/<branch>
  sub = "repo:cogini/*"
}
