# Create Route53 delgation set
#
# A delegation set is a set of nameservers which will be used when creating a
# zone. It's useful to create it separately from the zone, as you can then
# specify the nameservers for the domain in the registrar and they will stay
# the same even if you delete the Route53 zone and create it again.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//route53-delegation-set"
# }
# dependencies {
#   paths = []
# }
# include {
#   path = find_in_parent_folders()
# }

# https://www.terraform.io/docs/providers/aws/r/route53_delegation_set.html
resource "aws_route53_delegation_set" "main" {
  reference_name = var.reference_name
}
