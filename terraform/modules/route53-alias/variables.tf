variable "dns_domain" {
  description = "Route53 DNS domain (zone name)"
}

variable "dns_zone_id" {
  description = "Route53 zone_id"
}

variable "host_name" {
  description = "Host part of DNS name, default www"
  default = "www"
}

variable "target_name" {
  description = "DNS name of target: LB dns_name, CF domain_name, S3 website_endpoint"
}

variable "target_zone_id" {
  description = "DNS zone_id of target: LB zone_id, CF hosted_zone_id, S3 hosted_zone_id"
}

variable "alias_domain" {
  description = "Create Route53 record for bare domain"
  default = false
}
