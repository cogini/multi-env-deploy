variable "comp" {
  description = "Name of the app component, app, worker, etc."
  default     = "app"
}

variable "s3_buckets" {
  description = "S3 bucket access"
  type        = map(any)
  default     = {}
}

variable "ssm_ps_param_prefix" {
  description = "Prefix for SSM Parameter Store parameters, default env/org/app/comp"
  default     = ""
}

variable "ssm_ps_params" {
  description = "Names of SSM Parameter Store parameters"
  type        = list(any)
  default     = []
}

variable "cloudfront_create_invalidation" {
  description = "Allow role to invalidate CloudFront distributions"
  default     = false
}

variable "codestar_connection_arn" {
  description = "CodeStar Connection ARN"
  default     = null
}

variable "codepipeline_service_role_id" {
  description = "CodePipeline service role"
}

variable "codedeploy_service_role_id" {
  description = "CodeDeploy service role"
}

variable "codebuild_service_role_id" {
  description = "CodeBuild service role"
}

variable "artifacts_bucket_arn" {
  description = "Artifacts S3 bucket"
}

variable "cache_bucket_arn" {
  description = "Build cache S3 bucket"
}
