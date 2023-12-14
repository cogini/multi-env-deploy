# Create Route53 hosted zone for public domain

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//route53-zone"
}
dependency "delegation-set" {
  config_path = "../route53-delegation-set"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name = "rubegoldberg.io"
  delegation_set_id = dependency.delegation-set.outputs.id

  # Useful in dev, unsafe in prod
  force_destroy = true
}
