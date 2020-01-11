output "deployer_policy_id" {
  description = "Deployer policy id"
  value       = aws_iam_policy.codedeploy-app-deploy.id
}

output "deployer_policy_arn" {
  description = "Deployer policy arn"
  value       = aws_iam_policy.codedeploy-app-deploy.arn
}

output "deployer_policy_description" {
  description = "Deployer policy description"
  value       = aws_iam_policy.codedeploy-app-deploy.description
}

output "deployer_policy_name" {
  description = "Deployer policy name"
  value       = aws_iam_policy.codedeploy-app-deploy.name
}

output "deployer_policy_path" {
  description = "Deployer policy path"
  value       = aws_iam_policy.codedeploy-app-deploy.path
}

output "deployer_policy_policy" {
  description = "Deployer policy JSON"
  value       = aws_iam_policy.codedeploy-app-deploy.policy
}
