# CodeDeploy app
output "app_name" {
  description = "CodeDeploy app name"
  value       = aws_codedeploy_app.this.name
}

output "app_id" {
  description = "CodeDeploy app id"
  value       = aws_codedeploy_app.this.id
}
