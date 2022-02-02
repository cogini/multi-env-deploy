# Create CodeBuild project for GitHub Action

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codebuild-github-action"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "ecr-build" {
  config_path = "../ecr-build-app-ecs"
}
dependency "ecr" {
  config_path = "../ecr-app"
}
# dependencies {
#   paths = [
#     "../iam-codepipeline-app",
#   ]
# }
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  name = "foo-app-github-action-arm" # default app-comp

  environment_variables = {
    # ECS ECR registry
    REGISTRY = dependency.ecr.outputs.registry_id
    # ECS app ECR repository
    REPO_URL = dependency.ecr.outputs.repository_url
    PORT = 4000
  }

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
  
  # Intel
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

  # Allow running Docker daemon inside Docker container for ECS build
  codebuild_privileged_mode = true

  codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn
}
