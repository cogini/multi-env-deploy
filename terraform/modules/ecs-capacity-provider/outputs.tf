output "id" {
  description = "ECS capacity provider id"
  value       = aws_ecs_capacity_provider.this.id
}

output "arn" {
  description = "ECS capacity provider arn"
  value       = aws_ecs_capacity_provider.this.arn
}
