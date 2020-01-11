# DB instance
output "instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.this_db_instance_address
}

output "instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.db.this_db_instance_arn
}

output "instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.db.this_db_instance_availability_zone
}

output "instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db.this_db_instance_endpoint
}

output "instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.db.this_db_instance_hosted_zone_id
}

output "instance_id" {
  description = "The RDS instance ID"
  value       = module.db.this_db_instance_id
}

output "instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.db.this_db_instance_resource_id
}

output "instance_status" {
  description = "The RDS instance status"
  value       = module.db.this_db_instance_status
}

output "instance_name" {
  description = "The database name"
  value       = module.db.this_db_instance_name
}

output "instance_username" {
  description = "The master username for the database"
  value       = module.db.this_db_instance_username
}

output "instance_port" {
  description = "The database port"
  value       = module.db.this_db_instance_port
}
