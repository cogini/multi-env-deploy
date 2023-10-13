variable "service_role_arn" {
  description = "Lambda function IAM service role ARN"
}

variable "runtime" {
  description = "Lambda runtime"
  default     = "nodejs18.x"
}
