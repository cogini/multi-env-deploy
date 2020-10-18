output "arn" {
  description = "ECS task definition arn"
  value       = aws_ecs_task_definition.this.arn
}

output "family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.this.family
}

output "revision" {
  description = "ECS task definition revision"
  value       = aws_ecs_task_definition.this.revision
}

output "cpu" {
  description = "CPU spec"
  value       = aws_ecs_task_definition.this.cpu
}

output "memory" {
  description = "Memory spec"
  value       = aws_ecs_task_definition.this.memory
}

output "container_definitions" {
  description = "JSON for container definitions"
  value       = aws_ecs_task_definition.this.container_definitions
}

output "container_definitions_jsondecode" {
  description = "JSON for container definitions"
  value       = jsondecode(aws_ecs_task_definition.this.container_definitions)
}

output "ssm_ps_arn_param_prefix" {
  description = "Prefix for SSM Parameter Store ARN and parameters"
  value       = local.ssm_ps_arn_param_prefix
}

# output "task_role_arn" {
#   description = "ARN of IAM role that allows container task to call AWS services"
#   value       = aws_ecs_task_definition.this.task_role_arn
# }

# output "execution_role_arn" {
#   description = "ARN of IAM role that container agent uses to call AWS services"
#   value       = aws_ecs_task_definition.this.execution_role_arn
# }
