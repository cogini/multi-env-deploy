terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-ses-user"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
}
