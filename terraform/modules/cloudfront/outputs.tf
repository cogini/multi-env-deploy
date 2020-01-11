output "id" {
  value = aws_cloudfront_distribution.this.id
}

output "arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "status" {
  value = aws_cloudfront_distribution.this.status
}

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "etag" {
  value = aws_cloudfront_distribution.this.etag
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}
