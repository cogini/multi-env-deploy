# Create subdomain for environment e.g. dev.example.com

locals {
  fqdn = "${var.name}.${var.dns_domain}"
}

data "aws_route53_zone" "selected" {
  name = var.dns_domain
}

resource "aws_route53_zone" "sub" {
  name = local.fqdn

  tags = merge(
    {
      "Name"  = local.fqdn
      "org"   = var.org
      "env"   = var.env
      "app"   = var.app_name
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.sub.name_servers[0],
    aws_route53_zone.sub.name_servers[1],
    aws_route53_zone.sub.name_servers[2],
    aws_route53_zone.sub.name_servers[3],
  ]
}
