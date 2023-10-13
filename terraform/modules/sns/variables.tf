variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, org-app_name-env-comp if blank"
  default     = ""
}
