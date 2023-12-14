output "arn" {
  description = "Service ARN"
  value       = aws_service_discovery_service.this.arn
}

output "id" {
  description = "Service ID"
  value       = aws_service_discovery_service.this.id
}

output "name" {
  description = "Service name"
  value       = aws_service_discovery_service.this.name
}
