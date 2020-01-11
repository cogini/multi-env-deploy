output "role_name" {
  description = "Name of role with access to repo"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of role with access to repo"
  value       = aws_iam_role.this.arn
}

output "policy_name" {
  description = "Name of policy with access to repo"
  value       = aws_iam_policy.this.name
}

output "policy_arn" {
  description = "ARN of policy with access to repo"
  value       = aws_iam_policy.this.arn
}
