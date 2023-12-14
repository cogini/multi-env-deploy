output "id" {
  description = "ARN of SQS queue"
  value       = aws_sqs_queue.this.id
}

output "arn" {
  description = "ARN of SNS queue"
  value       = aws_sqs_queue.this.arn
}

output "url" {
  description = "ARN of SNS queue"
  value       = aws_sqs_queue.this.id
}
