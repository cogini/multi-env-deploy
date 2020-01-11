variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default = ""
}
