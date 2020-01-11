output "deployment_group_name" {
  description = "Deployment group name"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "deployment_group_id" {
  description = "Deployment group id"
  value       = aws_codedeploy_deployment_group.this.id
}
