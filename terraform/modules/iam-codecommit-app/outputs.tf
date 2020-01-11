output "role_name" {
  description = "Name of role with access to repo"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of role with access to repo"
  value       = aws_iam_role.this.arn
}
