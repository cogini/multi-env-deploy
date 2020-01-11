# Create Route53 DNS records to verify a domain for sending mail via SES

# Example route53-ses/terraform.tfvars
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//route53-ses"
# }
# dependency "zone" {
#   config_path = "../route53-public"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   # Domain used for sending mail, verified with SES
#   zone_name = dependency.zone.outputs.name
#   zone_id = dependency.zone.outputs.zone_id
#
#   aws_region = "us-east-1"
# }

locals {
  domain = replace(var.dns_domain, "/\\.$/", "") # zone_name has trailing dot
}

# https://www.terraform.io/docs/providers/aws/r/ses_domain_identity.html
resource "aws_ses_domain_identity" "default" {
  domain   = local.domain
}

# https://www.terraform.io/docs/providers/aws/r/ses_domain_dkim.html
resource "aws_ses_domain_dkim" "default" {
  domain   = aws_ses_domain_identity.default.domain
}

resource "aws_route53_record" "aws_ses_verification_record" {
  zone_id = var.dns_zone_id
  name    = "_amazonses"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.default.verification_token]
}

resource "aws_route53_record" "aws_ses_verification_record_dkim" {
  count   = 3
  zone_id = var.dns_zone_id
  name    = element(aws_ses_domain_dkim.default.dkim_tokens, count.index)
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.default.dkim_tokens[count.index]}.dkim.amazonses.com"]
}
