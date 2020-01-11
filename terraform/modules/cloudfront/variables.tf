variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "origin_bucket_arn" {
  description = "Origin bucket ARN"
}

variable "origin_bucket_id" {
  description = "Origin bucket id"
}

variable "origin_bucket_domain_name" {
  description = "Origin bucket bucket_domain_name"
}

variable "origin_path" {
  description = "Directory in S3 bucket CloudFront should read content from. Blank for root of bucket. Do not add a / at the end of the path."
  default     = ""
}

variable "logs_bucket_domain_name" {
  description = "Request logs bucket_domain_name"
}

variable "logs_bucket_path_prefix" {
  description = "Request logs bucket_domain_name"
  default  = "cloudfront/"
}

variable "host_name" {
  description = "Host part, e.g. assets for assets.example.com, www for www.example.com"
}

variable "alias_domain" {
  description = "Whether this distribution should handle the bare domain"
  default = false
}

variable "dns_domain" {
  description = "Route53 domain name (zone)"
}

variable "dns_zone_id" {
  description = "Route53 zone_id"
}

variable "enable_acm_cert" {
  description = "Use AWS Certificate Manager to manage cert"
  # Default to secure
  default     = true
  # Default to allow HTTP
  # default     = false
}

variable "enable_iam_cert" {
  description = "Use IAM to manage cert, exclusive to enable_acm_certificate"
  default     = false
}

variable "restrictions" {
  description = "Restrictions on CloudFront distribution"
  default = null
  # default = {
  #   geo_restriction = {
  #     restriction_type = "none"
  #   }
  # }
}

variable "price_class" {
  description = "Price class restrictions"
  # default     = "PriceClass_All" # PriceClass_All | PriceClass_200 | PriceClass_100
  default     = null
}

variable "default_ttl" {
  description = "Seconds before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header"
  default     = 3600
}

variable "min_ttl" {
  default = 0
}

variable "max_ttl" {
  default = 86400
}

variable "compress" {
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
  default     = true
}

variable "viewer_protocol_policy" {
  description = "allow-all, https-only, redirect-to-https"
  # Default to secure
  default     = "redirect-to-https"
  # Default to allow HTTP
  # default = "allow-all"
}

variable "create_dns" {
  description = "Create DNS record pointing to CloudFront"
  default     = true
}

variable "lambda_arn" {
  description = "Lambda@Edge function to map e.g. /about/ to /about/index.html"
  default = null
}
