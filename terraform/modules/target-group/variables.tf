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

variable "deregistration_delay" {
  description = "Draining time in secodns"
  default     = 300
}

variable "health_check" {
  description = "Mapping of tags for target group health_check"
  type        = map(any)
  default     = null
}

variable "stickiness" {
  description = "Mapping of tags for target group stickiness"
  type        = map(any)
  default     = null
}

variable "target_type" {
  description = "The type of target, values are instance: instance, ip, lambda"
  # Default "instance"
  default = null
}

variable "hosts" {
  description = "Host for listener rule condition, domain will be added"
  type        = list(string)
  default     = []
}

variable "paths" {
  description = "Hosts for listener rule condition, domain will be added"
  type        = list(string)
  # default     = ["/*"]
  default = []
}

variable "priority" {
  description = "Listener rule priority"
  default     = null
}

variable "vpc_id" {
  description = "VPC id"
}

variable "listener_arn" {
  description = "ARN of LB listner"
}

variable "listener_rule" {
  description = "Whether to add a listener rule"
  default     = true
}
