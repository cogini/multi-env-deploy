# Create service discovery private DNS namespace

# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//service-discovery-private-dns-namespace"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   name = "app.local"
# }

locals {
  # https://www.rfc-editor.org/rfc/rfc6762#appendix-G
  name = var.name == "" ? "${var.app_name}.internal" : var.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace
resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = local.name
  description = var.description
  vpc         = var.vpc_id

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags
  )
}
