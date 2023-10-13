output "dns_name" {
  description = "DNS name of RDS instance"
  value       = aws_route53_record.db[0].name
}

output "dns_fqdn" {
  description = "DNS name of RDS instance"
  value       = aws_route53_record.db[0].fqdn
}

output "dns_record" {
  description = "DNS name of RDS instance"
  value       = aws_route53_record.db[0]
}

# DB instance
output "instance_address" {
  description = "Address of RDS instance"
  value       = module.db.db_instance_address
}

output "instance_arn" {
  description = "ARN of RDS instance"
  value       = module.db.db_instance_arn
}

output "instance_availability_zone" {
  description = "Availability zone of RDS instance"
  value       = module.db.db_instance_availability_zone
}

output "instance_endpoint" {
  description = "Connection endpoint"
  value       = module.db.db_instance_endpoint
}

output "instance_hosted_zone_id" {
  description = "Canonical hosted zone ID of DB instance for use in Route53 Alias record"
  value       = module.db.db_instance_hosted_zone_id
}

output "instance_id" {
  description = "RDS instance ID"
  value       = module.db.db_instance_identifier
}

output "instance_resource_id" {
  description = "RDS Resource ID of instance"
  value       = module.db.db_instance_resource_id
}

output "instance_status" {
  description = "RDS instance status"
  value       = module.db.db_instance_status
}

output "instance_name" {
  description = "Database name"
  value       = module.db.db_instance_name
}

output "instance_username" {
  description = "Master username for database"
  value       = module.db.db_instance_username
  sensitive   = true
}

output "instance_port" {
  description = "Database port"
  value       = module.db.db_instance_port
}
