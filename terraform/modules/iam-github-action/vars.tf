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
  type        = map(any)
  default     = {}
}

# Configure for AWS environment, e.g. China (Beijing) Region
# https://docs.aws.amazon.com/AmazonS3/latest/dev/s3-arn-format.html
variable "aws_partition" {
  description = "AWS Partition: aws or aws-cn for China"
  default     = "aws"
}

variable "has_kms" {
  description = "Whether KMS is available"
  default     = true
}
