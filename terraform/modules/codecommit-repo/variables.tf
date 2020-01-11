variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "repository_name" {
  description = "Name of repository"
  default     = ""
}

variable "repository_default_branch" {
  description = "Default branch to use"
  default     = "master"
}

# variable "repository_desciption" {
#   description = "Description of repository"
# }
