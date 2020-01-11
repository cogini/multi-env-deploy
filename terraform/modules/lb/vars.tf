# Common vars used to name and tag things

variable "org" {
  description = "The organization, short name"
}

variable "org_unique" {
  description = "The organization, globally unique name for e.g. S3 buckets"
}

variable "app_name" {
  description = "The application name (hyphenated)"
}

variable "env" {
  description = "Environment, e.g. prod, stage, dev"
}

variable "owner" {
  description = "Creator of resources, e.g. ops or jake"
}

variable "extra_tags" {
  description = "Extra tags to attach to things"
  type        = map
  default     = {}
}

# For referencing bucket state in modules

variable "remote_state_s3_bucket_region" {
  description = "AWS region for state file, e.g. us-east-1"
}

variable "remote_state_s3_bucket_name" {
  description = "Bucket name for remote state, e.g. org-project-tfstate"
}

variable "remote_state_s3_key_prefix" {
  description = "Prefix in bucket where config starts, e.g. stage/ or project/stage/"
}

# Configure for AWS environment, e.g. China (Beijing) Region

# https://docs.aws.amazon.com/AmazonS3/latest/dev/s3-arn-format.html
variable "aws_partition" {
  description = "aws is a common partition name. aws-cn for China"
  default     = "aws"
}

variable "aws_service_endpoint_ec2" {
  description = "EC2 endpoint"
  default     = "ec2.amazonaws.com"
}

variable "has_kms" {
  description = "Whether KMS is available"
  default     = true
}
