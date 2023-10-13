# Create CodeBuild project for GitHub Action

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codebuild-github-action"
# }
# dependency "iam" {
#   config_path = "../iam-codepipeline"
# }
# dependency "ecr-build" {
#   config_path = "../ecr-build-app-ecs"
# }
# dependency "ecr" {
#   config_path = "../ecr-app"
# }
# # dependencies {
# #   paths = [
# #     "../iam-codepipeline-app",
# #   ]
# # }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#   name = "foo-app-github-action-arm" # default app-comp
#
#   environment_variables = {
#     # ECS ECR registry
#     REGISTRY = dependency.ecr.outputs.registry_id
#     # ECS app ECR repository
#     REPO_URL = dependency.ecr.outputs.repository_url
#     PORT = 4000
#   }
#
#   # Build
#   # Build image, either AWS standard or custom from ECR
#   # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
#   # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
#   # codebuild_image = "aws/codebuild/standard:4.0"
#   codebuild_image = "${dependency.ecr-build.outputs.repository_url}:latest"
#   buildspec = "ecs/buildspec.yml"
#
#   # Intel
#   # codebuild_compute_type = "BUILD_GENERAL1_MEDIUM"
#
#   # ARM
#   # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
#   # aws codebuild list-curated-environment-images
#   # codebuild_image = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
#   # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
#   codebuild_type = "ARM_CONTAINER"
#   codebuild_compute_type = "BUILD_GENERAL1_LARGE"
#
#   # codebuild_cache_type = "LOCAL"
#   # codebuild_cache_modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE", "LOCAL_CUSTOM_CACHE"]
#
#   # Allow running Docker daemon inside Docker container for ECS build
#   codebuild_privileged_mode = true
#
#   codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

data "aws_caller_identity" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project
# https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli
# https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec-ref-name-storage
resource "aws_codebuild_project" "this" {
  name          = local.name
  description   = "Build ${local.name}"
  service_role  = var.codebuild_service_role_arn
  build_timeout = var.build_timeout

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    # Overridden by GitHub Action
    type     = "GITHUB"
    location = "https://github.com/cogini/dummy"

    # git_clone_depth = 1

    # git_submodules_config {
    #   fetch_submodules = true
    # }
  }

  cache {
    type  = var.codebuild_cache_type
    modes = var.codebuild_cache_modes
  }

  environment {
    type                        = var.codebuild_type
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    privileged_mode             = var.codebuild_privileged_mode
    image_pull_credentials_type = var.codebuild_image_pull_credentials_type

    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html

    environment_variable {
      name  = "APPLICATION_NAME"
      value = var.app_name
    }

    environment_variable {
      name  = "ENVIRONMENT_NAME"
      value = var.env
    }

    environment_variable {
      name  = "COMPONENT_NAME"
      value = var.comp
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )
}
