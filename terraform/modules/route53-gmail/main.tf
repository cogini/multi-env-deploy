# Create Route53 DNS MX records for Gmail
#
# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/_envcommon//route53-gmail"
# }
# dependency "route53" {
#   config_path = "../route53-public"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   dns_domain = dependency.route53.outputs.name
#   dns_zone_id = dependency.route53.outputs.zone_id
#   # ttl = 60
# }

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name = var.zone_name
  type = "MX"
  records = [
    "10 ASPMX.L.GOOGLE.COM",
    "20 ALT1.ASPMX.L.GOOGLE.COM",
    "30 ALT2.ASPMX.L.GOOGLE.COM",
    "40 ASPMX2.GOOGLEMAIL.COM",
    "50 ASPMX3.GOOGLEMAIL.COM",
  ]
  ttl = var.ttl
}
