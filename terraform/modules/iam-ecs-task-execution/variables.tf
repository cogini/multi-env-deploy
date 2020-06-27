variable "comp" {
  description = "Component, e.g. app, worker"
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

variable "cloudwatch_logs_create_group" {
  description = "Allow role to create CloudWatch Logs groups"
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

variable "kms_key_arn" {
  description = "KMS CMK key ARN"
  default     = null
}
