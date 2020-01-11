variable "comp" {
  description = "Component, e.g. app, worker"
  default     = "app"
}

variable "artifacts_bucket_arn" {
  description = "Artifacts S3 bucket"
}

variable "role_name" {
  description = "IAM role with permissions to deploy"
}
