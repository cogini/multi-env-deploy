variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "target_group_arn" {
  description = "Target Groupt ARN"
}

variable "ips" {
  description = "IP addresses of EC2 instances"
}

variable "port" {
  description = "The port on which targets receive traffic"
  default     = "443"
}
