variable "name" {
  description = "Role name"
  default     = ""
}

variable "codebuild_project_name" {
  description = "CodeBuild project name"
}

variable "sub" {
  description = "GitHub repo allowed to run CodeBuild project, e.g. repo:cogini/*"
}
