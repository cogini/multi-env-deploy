# Create CloudFront distribution for files from an S3 bucket
#
# Typically this would be:
#
# * assets: CSS and JS files built by the app asset pipeline
#
# * public_web: app files which should be publicly available without
#   login. For example, in a "white label" website, customer logos
#   would be available on the login screen.
#
# * The public website for the app domain, built with a static site generator
#
# Subdomain is specified by host_name, e.g. "assets" for assets.example.com.
#
# Sets up Route53 alias pointing to CloudFront.
#
# This assumes that the origin is an S3 bucket, with all public access via CloudFront.
#
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html#concept_S3Origin
# http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesOriginPath
#
# Example config:

locals {
  cert_domain = replace(var.dns_domain, "/\\.$/", "") # zone_name has trailing dot, but cert does not
  fqdn        = "${var.host_name}.${local.cert_domain}"
  aliases     = var.alias_domain ? [local.cert_domain, local.fqdn] : [local.fqdn]
  has_cert    = (var.enable_acm_cert || var.enable_iam_cert)
}

data "aws_caller_identity" "current" {
}

# Certificate managed by ACM
data "aws_acm_certificate" "host_acm" {
  provider = aws.cloudfront
  count    = var.enable_acm_cert ? 1 : 0
  domain   = local.cert_domain
  statuses = ["ISSUED"]
}

# Certificate managed external to AWS, e.g. in China where ACM is not available
data "aws_iam_server_certificate" "host_iam" {
  provider = aws.cloudfront
  count    = var.enable_iam_cert ? 1 : 0
  name     = "*.${local.cert_domain}"
  latest   = true
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${var.app_name}-${var.env}-${var.comp}"
}

# Give CloudFront access to bucket where assets are stored
data "aws_iam_policy_document" "cloudfront" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.origin_bucket_arn]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.origin_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.origin_bucket_id
  policy = data.aws_iam_policy_document.cloudfront.json
}

# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html
# https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_UpdateDistribution.html
resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = var.price_class

  default_root_object = "index.html"
  comment             = "${var.app_name} ${var.env} ${var.host_name}"

  # http_version = "http2"

  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
    origin_path = var.origin_path

    domain_name = var.origin_bucket_domain_name
    origin_id   = var.origin_bucket_id
  }

  logging_config {
    bucket          = var.logs_bucket_domain_name
    prefix          = "${var.logs_bucket_path_prefix}${local.fqdn}"
    include_cookies = false
  }

  # ACM cert
  dynamic "viewer_certificate" {
    for_each = var.enable_acm_cert ? list(1) : []

    content {
      acm_certificate_arn      = data.aws_acm_certificate.host_acm[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  # IAM cert
  dynamic "viewer_certificate" {
    for_each = var.enable_iam_cert ? list(1) : []

    content {
      acm_certificate_arn      = data.aws_aam_certificate.host_iam[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  # Default cert
  dynamic "viewer_certificate" {
    for_each = local.has_cert ? [] : list(1)

    content {
      cloudfront_default_certificate = true
    }
  }

  aliases = local.has_cert ? local.aliases : []

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # custom_error_response {
  #   error_code    = 403
  #   response_code = 200
  #   response_page_path = "/index.html"
  # }

  # custom_error_response {
  #   error_code    = 404
  #   response_code = 200
  #   response_page_path = "/index.html"
  # }

  default_cache_behavior {
    # allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_bucket_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    # trusted_signers = [data.aws_caller_identity.current.account_id]

    dynamic "lambda_function_association" {
      for_each = var.lambda_arn == null ? [] : list(1)
      content {
        event_type = "origin-request"
        lambda_arn = var.lambda_arn
        # include_body = false
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress
  }

  tags = merge(
    {
      "Name"  = local.fqdn
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-cloudfront-distribution.html

# resource "aws_route53_record" "this" {
#   count = "${var.create_public_dns ? 1 : 0}"
#   zone_id = var.dns_zone_id
#   name    = "${var.assets_fqdn}"
#   type    = "CNAME"
#   ttl     = "300"
#   records = ["${aws_cloudfront_distribution.this.domain_name}"]
# }

# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html
resource "aws_route53_record" "this" {
  count = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = "${var.host_name}.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "this-aaaa" {
  count = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = "${var.host_name}.${var.dns_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
}
