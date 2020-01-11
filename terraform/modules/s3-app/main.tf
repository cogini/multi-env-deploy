# Create S3 buckets for app

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//s3-app"
# }
# dependency "kms" {
#   config_path = "../kms"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   # Force S3 buckets to be deleted even when they are not empty
#   # This is useful in dev, but dangerous in prod
#   force_destroy = true
#
#   buckets = {
#     # App assets such as CSS and JS published via CDN
#     assets = {
#     }
#     # Config files
#     config = {
#       encrypt = true
#     }
#     # Data files
#     data = {
#       encrypt = true
#     }
#     # Log files
#     logs = {
#       encrypt= true
#     }
#     # App public web files, e.g. user logos for whitelabel
#     public_web = {
#       website = true
#       acl = "public-read"
#     }
#     # App web files with controlled access, e.g. user data
#     protected_web = {
#       website = true
#       encrypt = true
#     }
#     # SSM files
#     ssm = {
#       encrypt = true
#     }
#
#     # CodeBuild cache
#     build_cache = {
#       encrypt = true
#     }
#     # CodePipeline deploy
#     deploy = {
#       encrypt = true
#     }
#   }
#
#   kms_key_id = dependency.kms.outputs.key_arn
# }

locals {
  bucket_prefix = var.bucket_prefix == "" ? "${var.org_unique}-${var.app_name}-${var.env}-${var.comp}" : var.bucket_prefix
  buckets = {
    for key, bucket in var.buckets:
    key => {
      name = lookup(bucket, "name", "${local.bucket_prefix}-${replace(key, "_", "-")}")
      encrypt = lookup(bucket, "encrypt", false)
      website = lookup(bucket, "website", false)
      # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
      acl = lookup(bucket, "acl", "private")
      versioning = lookup(bucket, "versioning", false)
    }
  }
}

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
# https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
# https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html
resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets
  bucket = each.value.name
  acl = each.value.acl

  dynamic "server_side_encryption_configuration" {
    for_each = each.value.encrypt ? list(1) : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = var.kms_key_id
          sse_algorithm     = var.sse_algorithm
        }
      }
    }
  }

  # cors_rule {
  #   allowed_headers = var.cors_allowed_headers
  #   allowed_methods = var.cors_allowed_methods
  #   allowed_origins = var.cors_allowed_origins
  #   expose_headers  = var.cors_expose_headers
  #   max_age_seconds = var.cors_max_age_seconds
  # }

  dynamic "website" {
    for_each = each.value.website ? list(1) : []
    content {
      index_document = "index.html"
      error_document = "404.html"
    }
  }

  # versioning {
  #   enabled = each.value.versioning
  # }

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

  force_destroy = var.force_destroy
}
