output "id" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.id
}

output "arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}
