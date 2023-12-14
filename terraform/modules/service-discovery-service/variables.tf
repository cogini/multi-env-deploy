variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "dns_ttl" {
  description = "DNS TTL for records"
  default = 10
}

variable "health_check_failure_threshold" {
  description = "The number of 30-second intervals that service discovery shoudl wait before changing health status of service instance. Max 10."
  default = null
}

variable "name" {
  description = "Name of service"
  default = ""
}

variable "namespace_id" {
  description = "Service Discovery namespace ID"
  default     = null
}

variable "routing_policy" {
  description = "The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service: MULTIVALUE or WEIGHTED"
  default = null
}
