# Create SNS topic

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sns"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}
inputs = {
  comp = "codedeploy"
  name = "foo-dev-codedeploy"
}
