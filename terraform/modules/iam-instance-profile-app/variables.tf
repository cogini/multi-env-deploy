variable "comp" {
  description = "Component, e.g. app, worker"
}

variable "s3_buckets" {
  description = "S3 bucket access"
  type        = map
  default     = {}
}

variable "cloudwatch_logs_prefix" {
  description = "CloudWatch Logs, arn:aws:logs:*:* if blank"
  default     = ""
}

variable "cloudwatch_logs" {
  description = "CloudWatch Logs"
  type        = list
  default     = []
}

variable "enable_ssm_management" {
  description = "Allow instance to be managed via SSM"
  default     = false
}

variable "ssm_ps_param_prefix" {
  description = "Prefix for SSM Parameter Store parameters, default env/org/app/comp"
  default     = ""
}

variable "ssm_ps_params" {
  description = "Names of SSM Parameter Store parameters"
  type        = list
  default     = []
}

variable "enable_codedeploy" {
  description = "Allow instance to install via CodeDeploy"
  default     = false
}

variable "enable_ec2_readonly" {
  description = "Allow instance to read EC2 details from other instances"
  default     = false
}

variable "enable_ec2_describe_instances" {
  description = "Enable reading EC2 instance metadata"
  default     = false
}

variable "kms_key_arn" {
  description = "KMS CMK key ARN"
  default     = null
}

variable "artifacts_bucket_arn" {
  description = "S3 bucket with CodePipeline artifacts, needed for CodeDeploy"
  default = ""
}
