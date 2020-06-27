terraform {
  source = "${get_terragrunt_dir()}/../../../modules//ecr-build"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
  name = "foo-worker-build"
}
