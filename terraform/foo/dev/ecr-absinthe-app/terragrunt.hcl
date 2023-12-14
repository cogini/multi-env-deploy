terraform {
  source = "${dirname(find_in_parent_folders())}/modules//ecr-build"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "api"
  name = "absinthe-app"
}
