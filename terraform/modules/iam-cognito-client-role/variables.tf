variable "amr" {
  description = "Authentication Methods References"
  default     = "unauthenticated"
}

variable "application_name" {
  description = "RUM Application Name"
  default     = ""
}

variable "aws_account_id" {
  description = "AWS account id"
  default     = ""
}

variable "comp" {
  description = "Component"
}

variable "identity_pool_id" {
  description = "Cognito identity pool id"
}

variable "role_name" {
  description = "Role name"
  default     = ""
}
