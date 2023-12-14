# Create Cognito Identity Pool
# https://www.paulmowat.co.uk/blog/cloudwatch-rum-cognito-sam-cloudformation
#
# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//cognito-identity-pool"
# }
# 
# include "root" {
#   path = find_in_parent_folders()
# }
# 
# inputs = {
#   # identity_pool_name = "foo" # Default is app_name-comp
#   comp = "app"
# 
#   allow_unauthenticated_identities = true
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool
resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = local.name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
}
