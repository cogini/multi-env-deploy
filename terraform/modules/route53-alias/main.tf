# Create Route53 DNS alias pointing to load balancer, CloudFront distribution
# or S3 bucket.
#
# This creates records for a host and optionally for the base domain.
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html
#
# Note that name of the record must match the name of your Amazon S3 bucket,
# and the bucket must be configured for website hosting.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//route53-alias"
# }
# dependency "route53" {
#   config_path = "../route53-public"
# }
# dependency "lb" {
#   config_path = "../lb-public"
# }
# # dependency "cloudfront" {
# #   config_path = "../cloudfront-public-web"
# # }
# # dependency "s3" {
# #   config_path = "../s3-app"
# # }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   # Name of host part, e.g. www for www.example.com
#   host_name = "www"
#   # Whether to create alias for the domain, e.g. example.com
#   alias_domain = true
#
#   dns_domain = dependency.route53.outputs.name
#   dns_zone_id = dependency.route53.outputs.zone_id
#
#   # LB
#   target_name = dependency.lb.outputs.dns_name
#   target_zone_id = dependency.lb.outputs.zone_id
#
#   # CloudFront
#   # target_name = dependency.cloudfront.outputs.domain_name
#   # target_name = dependency.cloudfront.outputs.hosted_zone_id
#
#   # S3 bucket
#   target_name = dependency.s3.outputs.buckets["protected_web"].website_endpoint
#   target_zone_id = dependency.s3.outputs.buckets["protected_web"].hosted_zone_id
# }

locals {
  fqdn = "${var.host_name}.${var.dns_domain}"
}

# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html
resource "aws_route53_record" "domain" {
  count = var.alias_domain ? 1 : 0
  zone_id = var.dns_zone_id
  name    = var.dns_domain
  type    = "A"

  alias {
    name                   = var.target_name
    zone_id                = var.target_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "domain-aaaa" {
  count = var.alias_domain ? 1 : 0

  zone_id = var.dns_zone_id
  name    = var.dns_domain
  type    = "AAAA"

  alias {
    name                   = var.target_name
    zone_id                = var.target_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "host" {
  zone_id = var.dns_zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = var.target_name
    zone_id                = var.target_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "host-aaaa" {
  zone_id = var.dns_zone_id
  name    = local.fqdn
  type    = "AAAA"

  alias {
    name                   = var.target_name
    zone_id                = var.target_zone_id
    evaluate_target_health = true
  }
}
