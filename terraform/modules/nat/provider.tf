terraform {
  backend "s3" {
  }
  required_version = ">= 0.12"
}

provider "aws" {
  alias   = "cloudfront"
  region  = "us-east-1"
  version = "~> 2.0"
}

# https://www.terraform.io/docs/modules/usage.html#passing-providers-explicitly
# https://git.io/fh0qw

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}
