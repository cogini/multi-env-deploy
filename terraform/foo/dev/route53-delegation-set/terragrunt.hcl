# Create Route53 delgation set
#
# This is a set of nameservers which will be used when creating a zone.
# It's useful to create it separately from the zone, as you can then specify
# the nameservers for the domain in the registrar and they will stay the same
# even if you delete the Route53 zone and create it again.

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//route53-delegation-set"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}
