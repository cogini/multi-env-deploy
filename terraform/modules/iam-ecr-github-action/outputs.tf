output "role_id" {
  description = "IAM role id"
  value       = aws_iam_role.this.id
}

output "role_arn" {
  description = "IAM role arn"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Role name"
  value       = aws_iam_role.this.name
}
