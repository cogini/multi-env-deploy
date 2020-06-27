output "id" {
  description = "Service arn"
  value       = aws_ecs_service.this.id
}

output "name" {
  description = "Service name"
  value       = aws_ecs_service.this.name
}

output "cluster" {
  description = "Cluster ARN"
  value       = aws_ecs_service.this.cluster
}

output "iam_role" {
  description = "The ARN of IAM role used for ELB"
  value       = aws_ecs_service.this.iam_role
}

output "desired_count" {
  description = "Number of instances of task definition"
  value       = aws_ecs_service.this.desired_count
}
