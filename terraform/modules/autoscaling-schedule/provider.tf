terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  version = "~> 2.14"
}
