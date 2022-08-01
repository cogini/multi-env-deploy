variable "name" {
  description = "Role name"
  default     = ""
}

variable "sub" {
  description = "GitHub repo allowed access, e.g. repo:cogini/*"
}

variable "ecr_arn" {
  description = "ARN of ECR repository"
}
