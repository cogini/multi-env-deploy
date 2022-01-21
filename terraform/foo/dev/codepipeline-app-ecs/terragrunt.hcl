# Create CodePipeline to build and deploy app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codepipeline"
}
dependency "vpc" {
  config_path = "../vpc"
}
# dependency "sg" {
#   config_path = "../sg-build-app"
# }
dependency "kms" {
  config_path = "../kms"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3" {
  config_path = "../s3-app"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-app"
}
dependency "ecr-build" {
  config_path = "../ecr-build-app-ecs"
}
dependency "ecr-build-cache" {
  config_path = "../ecr-build-cache-app-ecs"
}
dependency "ecr" {
  config_path = "../ecr-app"
}
dependency "codestar-connection" {
  config_path = "../codestar-connection"
}
# dependency "cloudfront" {
#   config_path = "../cloudfront-app-assets"
# }
# dependency "codecommit-repo" {
#   config_path = "../codecommit-repo-app"
# }
dependency "codedeploy-app" {
  config_path = "../codedeploy-app-ecs"
}
dependency "codedeploy-deployment-ecs" {
  config_path = "../codedeploy-deployment-app-ecs"
}
# dependency "zone" {
#   config_path = "../route53-public"
#   # config_path = "../route53-cdn" # separate CDN domain
# }
dependency "iam-task" {
  config_path = "../iam-ecs-task-role-app"
}
dependency "iam-execution" {
  config_path = "../iam-ecs-task-execution"
}
dependency "task" {
  config_path = "../ecs-task-app"
}
dependency "service" {
  config_path = "../ecs-service-app"
}
dependencies {
  paths = [
    "../iam-codepipeline-app",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  name = "foo-app-ecs" # default app-comp

  environment_variables = {
    # ECS ECR registry
    REGISTRY = dependency.ecr.outputs.registry_id
    # ECS app ECR repository
    REPO_URL = dependency.ecr.outputs.repository_url
    # ECS app ECR repository
    CACHE_REPO_URL = dependency.ecr-build-cache.outputs.repository_url
    # ECS container name from service task definition
    CONTAINER_NAME = "foo-app"
    PORT = 4000
    TASK_ROLE_ARN = dependency.iam-task.outputs.arn
    EXECUTION_ROLE_ARN = dependency.iam-execution.outputs.arn
    CPU = dependency.task.outputs.cpu
    MEMORY = dependency.task.outputs.memory
    AWSLOGS_GROUP = "/ecs/${dependency.service.outputs.name}"
    AWSLOGS_STREAM_PREFIX = dependency.service.outputs.name
    CONFIG_S3_BUCKET = dependency.s3.outputs.buckets["config"].id
    CONFIG_S3_PREFIX = "app-ecs"
  }

  # Source
  codestar_connection_arn = dependency.codestar-connection.outputs.arn
  source_provider = "CodeStar"
  repo_name = "cogini/phoenix_container_example"

  # source_provider = "GitHub"
  # If private repo, set TF_VAR_github_oauth_token env var
  # repo_owner = "cogini"
  # repo_name = "ecs-flask-example"
  # repo_name = "phoenix_container_example"
  # repo_branch = "master"
  # repo_poll = true

  # source_provider = "CodeCommit"
  # repo_branch = "master"
  # repo_branch = dependency.codecommit-repo.outputs.default_branch
  # codecommit_repository_name = dependency.codecommit-repo.outputs.repository_name

  # Build
  # Build image, either AWS standard or custom from ECR
  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  # codebuild_image = "ubuntu:bionic"
  # codebuild_image = "centos:7"
  # codebuild_image = "aws/codebuild/standard:2.0"
  # codebuild_image = "aws/codebuild/docker:18.09.0"
  # codebuild_image = "aws/codebuild/standard:4.0"
  codebuild_image = "${dependency.ecr-build.outputs.repository_url}:latest"
  # buildspec = "ecs/buildspec.yml"
  buildspec = "ecs/buildspec-earthly.yml"
  # codebuild_compute_type = "BUILD_GENERAL1_MEDIUM"

  # ARM
  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  # codebuild_image = "aws/codebuild/amazonlinux2-aarch64-standard"
  # aws codebuild list-curated-environment-images
  # codebuild_image = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  codebuild_type = "ARM_CONTAINER"
  codebuild_compute_type = "BUILD_GENERAL1_LARGE"

  # codebuild_cache_type = "LOCAL"
  # codebuild_cache_modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]

  codebuild_cache_type = "S3"

  # Allow running Docker daemon inside Docker container for ECS build
  codebuild_privileged_mode = true

  # Deploy
  codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
  # codedeploy_deployment_groups = [
  #   dependency.codedeploy-deployment-ecs.outputs.deployment_group_name,
  # ]
  codedeploy_ecs_deployments = [
    {
      Name = "ECS"
      DeploymentGroupName = dependency.codedeploy-deployment-ecs.outputs.deployment_group_name
    }
  ]

  kms_key_arn = dependency.kms.outputs.key_arn
  codepipeline_service_role_arn = dependency.iam.outputs.codepipeline_service_role_arn
  codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn

  artifacts_bucket_id = dependency.s3-codepipeline.outputs.buckets["deploy"].id
  cache_bucket_id = dependency.s3-codepipeline.outputs.buckets["build_cache"].id

  # subnet_ids = dependency.vpc.outputs.subnets["private"]
  # security_group_ids = [dependency.sg.outputs.security_group_id]
  # vpc_id = dependency.vpc.outputs.vpc_id
}
