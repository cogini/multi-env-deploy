variable "name" {
  description = "Name of key, defaults to app_name-env"
  default     = ""
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key"
  default     = false
}

variable "enable_ec2_as" {
  description = "Allow AWS service linked role for EC2 auto scaling to mount encrypted EBS volumes"
  default     = false
}
