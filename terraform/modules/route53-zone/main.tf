# Create Route53 hosted zone for public domain.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//route53-zone"
# }
# dependency "delegation-set" {
#   config_path = "../route53-delegation-set"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   name = "example.com"
#   delegation_set_id = dependency.delegation-set.outputs.id
#
#   # Useful in dev, unsafe in prod
#   force_destroy = true
# }

resource "aws_route53_zone" "this" {
  name = var.name
  delegation_set_id = var.delegation_set_id
  force_destroy = var.force_destroy
}
