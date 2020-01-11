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

output "codebuild_service_role_id" {
  description = "CodeBuild service role id"
  value       = aws_iam_role.codebuild-service-role.id
}

output "codebuild_service_role_arn" {
  description = "CodeBuild service role arn"
  value       = aws_iam_role.codebuild-service-role.arn
}

output "codebuild_service_role_name" {
  description = "CodeBuild service role name"
  value       = aws_iam_role.codebuild-service-role.name
}

output "codepipeline_service_role_id" {
  value = aws_iam_role.codepipeline-service-role.id
}

output "codepipeline_service_role_arn" {
  value = aws_iam_role.codepipeline-service-role.arn
}

output "codepipeline_service_role_name" {
  description = "CodePipeline service role name"
  value       = aws_iam_role.codepipeline-service-role.name
}
