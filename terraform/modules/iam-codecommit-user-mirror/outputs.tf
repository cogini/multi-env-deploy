output "arn" {
  description = "IAM user arn"
  value       = aws_iam_user.this.arn
}

output "name" {
  description = "IAM user name"
  value       = aws_iam_user.this.name
}

output "unique_id" {
  description = "IAM user unique_id"
  value       = aws_iam_user.this.unique_id
}
