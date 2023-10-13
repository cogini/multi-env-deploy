variable "kms_key_id" {
  description = "KMS key id"
  default     = null
}

variable "codebuild_ecr" {
  description = "Give CodeBuild role access to ECR repositories"
  type        = bool
  default     = false
}
