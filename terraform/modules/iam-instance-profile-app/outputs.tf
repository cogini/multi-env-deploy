# Service role
output "instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.this.name
}

output "instance_profile_arn" {
  description = "Instance profile arn"
  value       = aws_iam_instance_profile.this.arn
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}
