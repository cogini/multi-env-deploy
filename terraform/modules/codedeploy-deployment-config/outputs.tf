output "id" {
  description = "Deployment config name"
  value       = aws_codedeploy_deployment_config.this.id
}

output "deployment_config_id" {
  description = "Deployment config id"
  value       = aws_codedeploy_deployment_config.this.deployment_config_id
}
