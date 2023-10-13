variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

# Scheduled Scaling
variable "autoscaling_actions" {
  description = "Define sheduled actions"
  type        = map(any)
  default     = {}
}
