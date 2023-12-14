# Create Service Discovery service
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service
#
# Example:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//service-discovery-service"
# }
# dependency "namespace" {
#   config_path = "../service-discovery-namespace"
# }
# include "root" {
#   path = find_in_parent_folders()
# }
# 
# inputs = {
#   comp    = "app"
#   namespace_id = dependency.namespace.outputs.id
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

resource "aws_service_discovery_service" "this" {
  name = local.name

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = var.dns_ttl
      type = "A"
    }

    routing_policy = var.routing_policy
  }

  dynamic "health_check_custom_config" {
    for_each = var.health_check_failure_threshold == null ? [] : tolist([1])
    content {
      failure_threshold = var.health_check_failure_threshold
    }
  }
}
