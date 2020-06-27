variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, var.app_name-var.comp if blank"
  default = ""
}

variable "environment_variables" {
  description = "Environment vars to make available to build"
  type        = map
  default     = {}
}

variable "codedeploy_app_name" {
  description = "CodeDeploy app comp name"
  default = ""
}

variable "codedeploy_deployment_groups" {
  description = "List of deployment group names"
  type        = list(string)
  default     = []
}

variable "codedeploy_ecs_deployments" {
  description = "List of CodeDeploy ECS configurations"
  type        = list
  default     = []
}

variable "ecs_deployments" {
  description = "List of ECS deploy configurations"
  type        = list
  default     = []
}

variable "manual_approval" {
  description = "Manual approval config"
  type        = map
  default     = null
}

variable "codecommit_repository_name" {
  description = "CodeCommit repository name"
  default = ""
}

variable "source_provider" {
  description = "Source Provider: CodeCommit or GitHub"
  default     = "GitHub"
}

variable "repo_branch" {
  description = "Branch of the repository"
  default     = "master"
}

variable "repo_owner" {
  description = "GitHub organization / person"
  default = ""
}

variable "repo_name" {
  description = "GitHub repository"
  default = ""
}

variable "repo_poll" {
  description = "Whether to poll repo for changes"
  default = false
}

# variable "github_oauth_token" {
#   description = "GitHub Oauth Token with permissions to access private repositories"
#   default     = null
# }

variable "codebuild_image" {
  description = "ECR image URL or predefined image name"
  # default     = "ubuntu:bionic"
  # default     = "centos:7"
}

variable "buildspec" {
  description = "Buildspec file name, e.g. subdir/buildspec.yml"
  default     = null
}

variable "codebuild_type" {
  description = "Type of build environment: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER or ARM_CONTAINER"
  default     = "LINUX_CONTAINER"
}

variable "codebuild_compute_type" {
  description = "Image size: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, and BUILD_GENERAL1_LARGE"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_privileged_mode" {
  description = "If true, enables running the Docker daemon inside a Docker container"
  default     = null
}

variable "codebuild_image_pull_credentials_type" {
  description = "Credentials CodeBuild uses to pull images: CODEBUILD or SERVICE_ROLE"
  default     = null
}

variable "codebuild_cache_type" {
  description = "Type of storage for project cache. NO_CACHE, LOCAL, or S3. Defaults NO_CACHE"
  default     = "S3"
}

variable "codebuild_cache_modes" {
  description = "LOCAL cache modes: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, and/or LOCAL_CUSTOM_CACHE"
  type        = list(string)
  # ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  default = null
}

variable "artifacts_bucket_id" {
  description = "S3 bucket for build and deploy artifacts"
}

variable "cache_bucket_id" {
  description = "S3 bucket for build cache"
}

variable "codepipeline_service_role_arn" {
  description = "CodePipeline IAM service role ARN"
}

variable "codebuild_service_role_arn" {
  description = "CodeBuild IAM service role ARN"
}

variable "vpc_id" {
  description = "VPC id"
  default     = null
}

variable "subnet_ids" {
  description = "VPC subnet ids"
  type        = list
  default     = []
}

variable "security_group_ids" {
  description = "Security group ids"
  type        = list
  default     = []
}

variable "build_timeout" {
  description = "Build timeout in minutes"
  default     = null
}
