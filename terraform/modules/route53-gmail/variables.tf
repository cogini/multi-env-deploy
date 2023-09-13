variable "zone_name" {
  description = "Route53 DNS zone name"
}

variable "zone_id" {
  description = "Route53 zone_id"
}

variable "ttl" {
  description = "Time To Live"
  default = 3600
}
