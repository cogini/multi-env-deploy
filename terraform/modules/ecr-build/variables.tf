variable "allow_codebuild" {
  description = "Set up IAM allowing AWS CodeBuild to access repository."
  default     = false
}

variable "comp" {
  description = "Name of the app component, app, worker, etc."
  default     = ""
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default     = ""
}

variable "cross_accounts" {
  description = "Principal of aws accounts like arn:aws:iam::account-id:root"
  type        = list(string)
  default     = []
}

variable "create_replication" {
  description = "Whether to enable replication"
  default     = false
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

variable "registry_replication_rules" {
  description = "Replication rules"
  type        = any
  default     = []
}

variable "scan_on_push" {
  description = "Whether images are scanned after being pushed to the repository"
  default     = false
}

variable "source_account" {
  description = "Enables replication from source"
  default     = ""
}
