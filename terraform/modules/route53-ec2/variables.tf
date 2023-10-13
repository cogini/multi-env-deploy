variable "dns_domain" {
  description = "Route53 zone_name (domain)"
}

variable "dns_zone_id" {
  description = "Route53 zone_id"
}

variable "host_name" {
  description = "Host part of DNS name, e.g. www"
  default     = "www"
}

variable "target_records" {
  description = "DNS records to point to"
  type        = list(any)
}

variable "alias_domain" {
  description = "Create Route53 record for DNS bare domain"
  default     = false
}

variable "dns_ttl" {
  description = "DNS record time to live"
  default     = 60
}

variable "dns_health_check" {
  description = "Enable Route53 health check"
  default     = false
}

variable "health_check_port" {
  description = "Route53 health check port"
  default     = 80
}

variable "health_check_type" {
  description = "Route53 health check type"
  default     = "HTTP"
}

variable "health_check_resource_path" {
  description = "Route53 health check resource_path"
  default     = "/"
}

variable "health_check_failure_threshold" {
  description = "Route53 health check failure_threshold"
  default     = "5"
}

variable "health_check_request_interval" {
  description = "Route53 health check request_interval"
  default     = "30"
}
