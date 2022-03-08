variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default = ""
}

variable "scan_on_push" {
  description = "Whether images are scanned after being pushed to the repository"
  default = false
}
