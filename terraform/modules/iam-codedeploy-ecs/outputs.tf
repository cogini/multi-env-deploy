output "codedeploy_service_role_id" {
  description = "CodeDeploy service role id"
  value       = aws_iam_role.codedeploy-service-role.id
}

output "codedeploy_service_role_arn" {
  description = "CodeDeploy service role arn"
  value       = aws_iam_role.codedeploy-service-role.arn
}

output "codedeploy_service_role_name" {
  description = "CodeDeploy service role name"
  value       = aws_iam_role.codedeploy-service-role.name
}
