variable "comp" {
  description = "Name of the app component, app, worker, etc."
  default     = "default"
}

# target group
variable "name" {
  description = "The name of the target group"
  default     = ""
}

variable "port" {
  description = "Listen port"
  default     = "80"
}

variable "protocol" {
  description = "Target group protocol"
  default     = "HTTP" # HTTP | HTTPS
}

variable "health_check" {
  description = "Mapping of tags for target group health_check"
  type        = map(any)
  default     = {}
}

variable "stickiness" {
  description = "Mapping of tags for target group stickiness"
  type        = map(any)
  default = {
    type            = "lb_cookie"
    enabled         = false
    cookie_duration = 86400
  }
}

variable "target_type" {
  description = "The type of target, values are instance: instance, ip, lambda"
  default     = "instance"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "protocol_version" {
  description = "Protocol version"
  default     = "HTTP1"
}
