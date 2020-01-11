output "domain_arn" {
  description = "Amazon Resource Name (ARN) of the domain"
  value       = aws_elasticsearch_domain.this.arn
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = aws_elasticsearch_domain.this.domain_id
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_elasticsearch_domain.this.endpoint
}
