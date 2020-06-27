output "id" {
  description = "Role id"
  value       = aws_iam_service_linked_role.this.id
}

output "arn" {
  description = "Role arn"
  value       = aws_iam_service_linked_role.this.arn
}

output "create_date" {
  description = "Role creation date"
  value       = aws_iam_service_linked_role.this.create_date
}

output "name" {
  description = "Role name"
  value       = aws_iam_service_linked_role.this.name
}

output "path" {
  description = "Role path"
  value       = aws_iam_service_linked_role.this.path
}

output "unique_id" {
  description = "Stable and unique string identifying the role"
  value       = aws_iam_service_linked_role.this.unique_id
}
