# Service role
output "instance_profile_name" {
  description = "IAM instance profile name"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "instance_profile_arn" {
  description = "Instance profile arn"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}
