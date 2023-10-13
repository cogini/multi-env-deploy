# Create IAM role that allows a GitHub Action to call AWS

include {
  path = find_in_parent_folders()
}

terraform {
  # source = "${dirname(find_in_parent_folders())}/modules//iam-github-action"
  source = "${get_terragrunt_dir()}/../../../modules//iam-github-action"
}

dependency "cloudfront" {
  config_path = "../cloudfront-public-web"
}
dependency "codedeploy-app" {
  config_path = "../codedeploy-app-ecs"
}
dependency "codedeploy-deployment" {
  config_path = "../codedeploy-deployment-app-ecs"
}
dependency "ecr" {
  config_path = "../ecr-app"
}
dependency "ecs-cluster" {
  config_path = "../ecs-cluster"
}
dependency "ecs-service" {
  config_path = "../ecs-service-app"
}
dependency "iam-ecs-task-execution" {
  config_path = "../iam-ecs-task-execution"
}
dependency "iam-ecs-task-role" {
  config_path = "../iam-ecs-task-role-app"
}
dependency "s3" {
  config_path = "../s3-app"
}

inputs = {
  comp = "app"

  sub = "repo:cogini/phoenix_container_example:*"

  s3_buckets = [
    dependency.s3.outputs.buckets["assets"].id
  ]

  enable_cloudfront = true

  ecr_arn = dependency.ecr.outputs.arn

  ecs = {
    cluster_name = dependency.ecs-cluster.outputs.name
    service_name = dependency.ecs-service.outputs.name
    task_role_arn = dependency.iam-ecs-task-role.outputs.arn
    execution_role_arn = dependency.iam-ecs-task-execution.outputs.arn
    codedeploy_application_name = dependency.codedeploy-app.outputs.app_name
    codedeploy_deployment_group_name = dependency.codedeploy-deployment.outputs.deployment_group_name
  }
}
