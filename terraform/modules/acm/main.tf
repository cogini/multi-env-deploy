# Create a certificate using Amazon Certificate Manager (ACM) with
# Route 53 DNS validation.

# Generates cert for the public domain and wildcard,
# e.g. example.com and *.example.com

# Load balancer certs need to be in the same region as the load balancer.
# AWS requires CloudFront certs to be in us-east-1.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//acm-public"
# }
# dependency "zone" {
#   config_path = "../route53-public"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   dns_domain = dependency.zone.outputs.name
#
#   # Whether to create Route53 records for validation
#   # Default is true, for primary load balancer cert.
#   # False when there is a cert already in another region, e.g. for CloudFront.
#   # create_route53_records = false
# }

locals {
  domain_name               = var.dns_domain
  subject_alternative_names = ["*.${local.domain_name}"]
}

data "aws_route53_zone" "selected" {
  name = local.domain_name
}

# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
resource "aws_acm_certificate" "default" {
  domain_name               = local.domain_name
  subject_alternative_names = local.subject_alternative_names
  validation_method         = "DNS"

  tags = merge(
    {
      "Name"  = local.domain_name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  # If this is a secondary cert, then the DNS records are already created by the primary
  for_each = {
    for dvo in var.create_route53_records ? aws_acm_certificate.default.domain_validation_options : [] : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.validation_record_ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn

  # validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]

  # Use an explicit dependency and get fqdn from domain_validation_options
  # instead of aws_route53_record.validation because we may be skipping the
  # creation of some route53 records, and we need to provide all validation
  # FQDNs, even if we do not create them.

  validation_record_fqdns = aws_acm_certificate.default.domain_validation_options[*].resource_record_name

  depends_on = [
    aws_route53_record.validation
  ]
}
