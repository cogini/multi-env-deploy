output "arn" {
  description = "Provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "tags_all" {
  description = "Tags"
  value       = aws_iam_openid_connect_provider.github.tags_all
}
