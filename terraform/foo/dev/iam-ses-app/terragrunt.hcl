terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-ses-user"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
}
