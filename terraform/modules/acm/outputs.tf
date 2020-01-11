output "arn" {
  value = aws_acm_certificate.default.arn
}

output "domain_name" {
  value = aws_acm_certificate.default.domain_name
}
