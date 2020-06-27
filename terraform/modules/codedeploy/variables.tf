variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, app_name-comp if blank"
  default = ""
}

variable "compute_platform" {
  description = "Type of deployment: ECS, Lambda, or Server"
  # Default is Server
  default     = null
}
