# Create S3 bucket for CloudFront access logs

# https://qiita.com/suzuki-navi/items/191a013b08d2aee15cfe
# https://dev.classmethod.jp/articles/s3-acl-error-from-202304/

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//s3-cloudfront-logs"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "cloudwatch-logs"
#   bucket_name = "xxx"
# }

locals {
  bucket_name = var.bucket_name == "" ? "${var.org_unique}-${var.app_name}-${var.env}-${var.comp}" : var.bucket_name
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = merge(
    {
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )
}


# AccessControlListNotSupported: The bucket does not allow ACLs
# https://dev.classmethod.jp/articles/s3-acl-error-from-202304/
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id

  # CloudFront log delivery group
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#access-logs-granting-permissions-to-cf-to-put-object-in-s3

  access_control_policy {
    owner {
      id = data.aws_canonical_user_id.current.id
    }

    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      # Grant CloudFront logs access to your Amazon S3 Bucket
      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
      grantee {
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
  }
}

# resource "aws_s3_bucket_lifecycle_configuration" "this" {
#   bucket = aws_s3_bucket.this.id
#
#   rule {
#     id     = "expiration"
#     status = "Enabled"
#
#     expiration {
#       days = var.retention
#     }
#
#     noncurrent_version_expiration {
#       noncurrent_days = 1
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "this" {
#   bucket = aws_s3_bucket.this.id
#
#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }
