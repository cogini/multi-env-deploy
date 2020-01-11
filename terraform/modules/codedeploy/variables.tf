variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "compute_platform" {
  description = "Type of deployment: ECS, Lambda, or Server"
  default     = "Server"
}
