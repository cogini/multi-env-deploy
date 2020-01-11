variable "dns_domain" {
  description = "Domain to create cert for, e.g. example.com"
}

variable "create_route53_records" {
  description = "Whether to create Route53 records for validation: true for primary, false for secondary cert."
  default     = true
}

variable "validation_record_ttl" {
  description = "Time-to-live for Route53 validation records"
  default     = 60
}
