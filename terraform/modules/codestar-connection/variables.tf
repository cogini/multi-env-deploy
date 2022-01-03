variable "name" {
  description = "Name, normally the GitHub organization"
  default = null
}

variable "provider_type" {
  description = "Source Provider: Bitbucket, GitHub or GitHubEnterpriseServer"
  default     = "GitHub"
}
