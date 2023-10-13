variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default     = ""
}

# https://docs.aws.amazon.com/AmazonECR/latest/userguide/pull-through-cache.html
variable "pull_through_cache_rules" {
  description = "Pull through cache rules"
  type = list(object({
    ecr_repository_prefix = string
    upstream_registry_url = string
  }))
  default = []
}

variable "scan_on_push" {
  description = "Whether images are scanned after being pushed to the repository"
  default     = false
}
