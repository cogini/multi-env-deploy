output "group_name" {
  description = "Name of group with access to repo"
  value       = aws_iam_group.this.name
}

output "group_arn" {
  description = "ARN of group with access to repo"
  value       = aws_iam_group.this.arn
}

output "policy_name" {
  description = "Name of policy with access to repo"
  value       = aws_iam_policy.this.name
}

output "policy_arn" {
  description = "ARN of policy with access to repo"
  value       = aws_iam_policy.this.arn
}
