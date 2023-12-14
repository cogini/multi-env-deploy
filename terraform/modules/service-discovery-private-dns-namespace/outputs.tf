output "id" {
  description = "ID of namespace"
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "arn" {
  description = "ARN of namespace"
  value       = aws_service_discovery_private_dns_namespace.this.arn
}

output "hosted_zone_id" {
  description = "Route53 hosted zone"
  value       = aws_service_discovery_private_dns_namespace.this.hosted_zone
}

output "dns_domain" {
  description = "DNS domain name"
  value       = local.name
}
