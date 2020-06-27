output "name" {
  description = "The name of the load balancer target group"
  value       = aws_lb_target_group.this.name
}

output "id" {
  description = "The ARN of the load balancer target group (matches arn)"
  value       = aws_lb_target_group.this.id
}

output "arn" {
  description = "The ARN of the default load balancer target group (matches id)"
  value       = aws_lb_target_group.this.arn
}

output "arn_suffix" {
  description = "The tg ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.this.arn_suffix
}
