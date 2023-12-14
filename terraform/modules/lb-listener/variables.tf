variable "loadbalancer_arn" {
  description = "Load Balancer to add listener to"
}

variable "dns_domain" {
  description = "DNS domain name, used to find certs"
  default     = ""
}

variable "enable_acm_cert" {
  description = "Use AWS Certificate Manager to manage cert"
  default     = true
}

variable "port" {
  description = "Port for listener"
}

variable "protocol" {
  description = "Protocol to listen for"
  default     = "HTTPS"
}

variable "target_group_arn" {
  description = "Target group to forward traffic to"
}
