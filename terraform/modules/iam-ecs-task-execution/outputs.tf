output "id" {
  description = "ECS Task Execution role id"
  value       = aws_iam_role.this.id
}

output "arn" {
  description = "ECS Task Execution role arn"
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "ECS Task Execution role name"
  value       = aws_iam_role.this.name
}
