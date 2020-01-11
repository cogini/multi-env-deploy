variable "comp" {
  description = "Name of the app component, app, worker, etc."
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
  type        = map
  default     = {}
}

variable "stickiness" {
  description = "Mapping of tags for target group stickiness"
  default = {
    type    = "lb_cookie"
    enabled = false
  }
}

variable "target_type" {
  description = "The type of target, values are instance: instance, ip, lambda"
  default     = "instance"
}

variable "host_name" {
  description = "Host for listener rule condition, domain will be added"
  default     = "*"
}

variable "hosts" {
  description = "Host for listener rule condition, domain will be added"
  default     = []
}

variable "paths" {
  description = "Hosts for listener rule condition, domain will be added"
  type        = list(string)
  default     = ["/*"]
}

# variable "priority" {
#   description = "Listener rule priority"
#   default     = ""
# }

variable "vpc_id" {
  description = "VPC id"
}

variable "listener_arn" {
  description = "ARN of LB listner"
}
