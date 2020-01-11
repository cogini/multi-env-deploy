# Create Route53 DNS record pointing to ec2 instances
#
# This creates records for a host and optionally for the base domain.
# It optionally adds a DNS health check.

locals {
  fqdn = "${var.host_name}.${var.dns_domain}"
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html
resource "aws_route53_record" "base" {
  count = var.alias_domain ? 1 : 0
  zone_id = var.dns_zone_id
  name    = var.dns_domain
  type    = "A"

  ttl     = var.dns_ttl
  records = var.target_records
}

resource "aws_route53_record" "host" {
  zone_id = var.dns_zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = var.dns_ttl
  records = var.target_records
}

resource "aws_route53_health_check" "base" {
  count             = (var.dns_health_check && var.alias_domain) ? 1 : 0
  fqdn              = var.dns_domain
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_resource_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_request_interval

  tags = {
    Name = "${var.app_name}-base"
  }
}

resource "aws_route53_health_check" "host" {
  count             = var.dns_health_check ? 1 : 0
  fqdn              = local.fqdn
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_resource_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_request_interval

  tags = {
    Name = "${var.app_name}-${var.host_name}-host"
  }
}
