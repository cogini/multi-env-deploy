variable "name" {
  description = "Used to override the var.app_name"
  default     = ""
}

variable "comp" {
  description = "Component, e.g. app, worker"
}

variable "s3_buckets" {
  description = "S3 bucket access"
  type        = map(any)
  default     = {}
}

variable "cloudwatch_logs_prefix" {
  description = "CloudWatch Logs, arn:aws:logs:*:* if blank"
  default     = ""
}

variable "cloudwatch_logs" {
  description = "CloudWatch Logs"
  type        = list(any)
  default     = []
}

variable "cloudwatch_metrics_namespace" {
  description = "CloudWatch metrics namespace, * for any"
  default     = ""
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

variable "xray" {
  description = "Allow sending traces to X-Ray"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS CMK key ARN"
  default     = null
}

variable "enable_ses" {
  description = "Allow sending to SES"
  default     = false
}

variable "enable_ssmmessages" {
  description = "Enable use of SSM messages"
  default     = false
}

variable "enable_transcribe" {
  description = "Enable use of AWS Transcribe"
  default     = false
}
