# Create a CD pipeline with CodePipeline, CodeBuild, CodeDeploy.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codepipeline"
# }
# dependency "kms" {
#   config_path = "../kms"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "sg" {
#   config_path = "../sg-build-app"
# }
# dependency "iam" {
#   config_path = "../iam-codepipeline"
# }
# dependency "s3" {
#   config_path = "../s3-app"
# }
# dependency "s3-codepipeline" {
#   config_path = "../s3-codepipeline-app"
# }
# dependency "ecr" {
#   config_path = "../ecr-app"
# }
# dependency "cloudfront" {
#   config_path = "../cloudfront-app-assets"
# }
# # dependency "codecommit-repo" {
# #   config_path = "../codecommit-repo-app"
# # }
# dependency "codedeploy-app" {
#   config_path = "../codedeploy-app"
# }
# dependency "codedeploy-deployment-asg" {
#   config_path = "../codedeploy-deployment-app-asg"
# }
# dependency "codedeploy-deployment-ec2" {
#   config_path = "../codedeploy-deployment-app-ec2"
# }
# dependencies {
#   paths = [
#     "../iam-codepipeline-app",
#   ]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   # Source
#   source_provider = "GitHub"
#   # If private repo, set TF_VAR_github_oauth_token env var
#   repo_owner = "cogini"
#   repo_name = "mix-deploy-example"
#   # repo_branch = "master"
#
#   # source_provider = "CodeCommit"
#   # repo_branch = "master"
#   # repo_branch = dependency.codecommit-repo.outputs.default_branch
#   # codecommit_repository_name = dependency.codecommit-repo.outputs.repository_name
#
#   # Build image, either AWS standard or custom from ECR
#   # build_image = "ubuntu:bionic"
#   # build_image = "centos:7"
#   build_image = "${dependency.ecr.outputs.repository_url}:latest"
#
#   # Deployment
#   codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
#   codedeploy_deployment_groups = [
#     dependency.codedeploy-deployment-asg.outputs.deployment_group_name,
#     dependency.codedeploy-deployment-ec2.outputs.deployment_group_name,
#   ]
#
#   kms_key_arn = dependency.kms.outputs.key_arn
#   codepipeline_service_role_arn = dependency.iam.outputs.codepipeline_service_role_arn
#   codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn
#
#   artifacts_bucket_id = dependency.s3-codepipeline.outputs.buckets["deploy"].id
#   cache_bucket_id = dependency.s3-codepipeline.outputs.buckets["build_cache"].id
#   subnet_ids = dependency.vpc.outputs.subnets["public"]
#   security_group_ids = [dependency.sg.outputs.security_group_id]
#   vpc_id = dependency.vpc.outputs.vpc_id
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  codebuild_cache_location = var.codebuild_cache_type == "S3" ? "${var.cache_bucket_id}/${local.name}" : null
}

data "aws_caller_identity" "current" {}

# https://www.terraform.io/docs/providers/aws/r/codebuild_project.html
# https://docs.aws.amazon.com/codebuild/latest/userguide/create-project.html#create-project-cli
# https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html#build-spec-ref-name-storage
resource "aws_codebuild_project" "this" {
  name          = local.name
  description   = "Build ${local.name}"
  service_role  = var.codebuild_service_role_arn
  build_timeout = var.build_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  cache {
    type      = var.codebuild_cache_type
    location  = local.codebuild_cache_location
    modes     = var.codebuild_cache_modes
  }

  # logs_config {
  #   cloudwatch_logs {
  #     group_name = "log-group"
  #     stream_name = "log-stream"
  #   }
  #
  #   s3_logs {
  #     status = "ENABLED"
  #     location = "${aws_s3_bucket.example.id}/build-log"
  #   }
  # }

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/vpc-support.html
  # https://aws.amazon.com/blogs/devops/access-resources-in-a-vpc-from-aws-codebuild-builds/
  dynamic "vpc_config" {
    for_each = var.vpc_id == null ? [] : list(1)
    content {
      vpc_id = var.vpc_id
      subnets = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  environment {
    type                        = var.codebuild_type
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    privileged_mode             = var.codebuild_privileged_mode
    image_pull_credentials_type = var.codebuild_image_pull_credentials_type

    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html

    environment_variable {
      name  = "ARTIFACTS_BUCKET"
      value = var.artifacts_bucket_id
    }

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

    dynamic "environment_variable" {
      for_each = var.environment_variables_ssm
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "PARAMETER_STORE"
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

# https://www.terraform.io/docs/providers/aws/r/codepipeline.html
resource "aws_codepipeline" "this" {
  name     = local.name
  role_arn = var.codepipeline_service_role_arn

  artifact_store {
    type     = "S3"
    location = var.artifacts_bucket_id

    dynamic "encryption_key" {
      for_each = var.kms_key_arn == null ? [] : list(1)
      content {
        id   = var.kms_key_arn
        type = "KMS"
      }
    }
  }

  stage {
    name = "Source"

    dynamic "action" {
      for_each = var.source_provider == "CodeCommit" ? list(1) : []
      content {
        name             = "Git"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit"
        version          = "1"
        output_artifacts = ["Source"]
        configuration = {
          RepositoryName = var.codecommit_repository_name
          BranchName     = var.repo_branch
          # https://docs.aws.amazon.com/codepipeline/latest/userguide/trigger-codecommit-migration-cwe.html
          PollForSourceChanges = true
        }
      }
    }

    dynamic "action" {
      for_each = var.source_provider == "GitHub" ? list(1) : []
      content {
        name             = "Git"
        category         = "Source"
        owner            = "ThirdParty"
        provider         = "GitHub"
        version          = "1"
        output_artifacts = ["Source"]
        configuration = {
          # https://github.com/terraform-providers/terraform-provider-aws/pull/5764
          # https://docs.aws.amazon.com/codepipeline/latest/userguide/GitHub-rotate-personal-token-CLI.html
          # GITHUB_TOKEN
          # OAuthToken = var.github_oauth_token
          # OAuthToken = data.aws_ssm_parameter.github_token.value
          Owner  = var.repo_owner
          Repo   = var.repo_name
          Branch = var.repo_branch
          # https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-webhooks-migration.html
          PollForSourceChanges = var.repo_poll
        }
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/approvals-action-add.html
  dynamic "stage" {
    for_each = var.manual_approval == null ? [] : list(1)
    content {
      name = "Approve"
      action {
        name            = "ManualApproval"
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        version         = "1"
        input_artifacts = []
        configuration = {
          NotificationArn = lookup(var.manual_approval, "NotificationArn", null)
          ExternalEntityLink = lookup(var.manual_approval, "ExternalEntityLink", null)
          CustomData = lookup(var.manual_approval, "CustomData", null)
        }
      }
    }
  }

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html

  dynamic "stage" {
    for_each = var.codedeploy_deployment_groups
    content {
      name = "Deploy"
      action {
        name            = "Deploy-${action.value}"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        version         = "1"
        input_artifacts = ["Build"]
        configuration = {
          ApplicationName     = var.codedeploy_app_name
          DeploymentGroupName = stage.value
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.ecs_deployments
    content {
      name = "Deploy"
      action {
        name            = lookup(action.value, "Name")
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        version         = "1"
        input_artifacts = ["Build"]
        configuration = {
          ClusterName = lookup(stage.value, "ClusterName", null)
          ServiceName = lookup(stage.value, "ServiceName", null)
          FileName = lookup(stage.value, "FileName", "imagedefinitions.json")
          DeploymentTimeout = lookup(stage.value, "DeploymentTimeout", null)
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.codedeploy_ecs_deployments
    content {
      name = "Deploy"
      action {
        name            = lookup(stage.value, "Name")
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        version         = "1"
        input_artifacts = ["Build"]
        configuration = {
          ApplicationName = lookup(stage.value, "ApplicationName", var.codedeploy_app_name)
          DeploymentGroupName = lookup(stage.value, "DeploymentGroupName")
          TaskDefinitionTemplateArtifact = lookup(stage.value, "TaskDefinitionTemplateArtifact", "Build")
          TaskDefinitionTemplatePath = lookup(stage.value, "TaskDefinitionTemplatePath", "taskdef.json")
          AppSpecTemplateArtifact = lookup(stage.value, "AppSpecTemplateArtifact", "Build")
          AppSpecTemplatePath = lookup(stage.value, "AppSpecTemplatePath", "appspec.yml")
          Image1ArtifactName = "Build"
          Image1ContainerName = "IMAGE1_NAME"
          # Image2ArtifactName
          # Image2ContainerName
          # Image3ArtifactName
          # Image3ContainerName
          # Image4ArtifactName
          # Image4ContainerName
        }
      }
    }
  }

}
  # https://dev.classmethod.jp/articles/codepipeline-ecs-codedeploy/
  # https://qiita.com/keroxp/items/7ae472bf7344c1efa021

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
