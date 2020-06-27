variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default     = ""
}

variable "auto_scaling_group_arn" {
  description = "ARN of auto scaling group"
}

variable "managed_scaling" {
  description = "Mapping of parameters for auto scaling"
  type        = map
  default     = {}
}

variable "managed_termination_protection" {
  description = "Whether to enable managed_termination_protection: ENABLED or DISABLED"
  default     = null
}
