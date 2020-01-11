variable "name" {
  description = "Name of key, defaults to app_name-env"
  default     = ""
}

variable "enable_ec2_as" {
  description = "Allow AWS service linked role for EC2 auto scaling to mount encrypted EBS volumes"
  default     = false
}
