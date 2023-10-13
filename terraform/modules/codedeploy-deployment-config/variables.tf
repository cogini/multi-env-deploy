variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, var.app_name-var.comp if blank"
  default     = ""
}

variable "compute_platform" {
  description = "Compute platform: Server, Lambda, or ECS, default Server"
  default     = null
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_config.html#argument-reference
variable "minimum_healthy_hosts_type" {
  description = "minimum_healthy_hosts type. HOST_COUNT or FLEET_PERCENT"
  default     = "HOST_COUNT"
}

variable "minimum_healthy_hosts_value" {
  description = "minimum_healthy_hosts value"
  default     = 1
}
