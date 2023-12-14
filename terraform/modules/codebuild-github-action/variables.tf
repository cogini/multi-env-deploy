variable "build_timeout" {
  description = "Build timeout in minutes"
  default     = null
}

variable "buildspec" {
  description = "Buildspec file name, e.g. subdir/buildspec.yml"
  default     = "buildspec.yml"
}

variable "codebuild_image" {
  description = "ECR image URL or predefined image name"
  # default     = "ubuntu:bionic"
  # default     = "centos:7"
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
  default     = null
}

variable "codebuild_cache_modes" {
  description = "LOCAL cache modes: LOCAL_SOURCE_CACHE, LOCAL_DOCKER_LAYER_CACHE, and/or LOCAL_CUSTOM_CACHE"
  type        = list(string)
  # ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  default = null
}

variable "codebuild_service_role_arn" {
  description = "CodeBuild IAM service role ARN"
}

variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "environment_variables" {
  description = "Environment vars to make available to build"
  type        = map(any)
  default     = {}
}

variable "environment_variables_ssm" {
  description = "Environment vars from ParameterStore to make available to build"
  type        = map(any)
  default     = {}
}

variable "fetch_submodules" {
  description = "Fetch git submodules"
  default     = true
}

variable "git_clone_depth" {
  description = "Truncate git history to this many commits"
  default     = 1
}

variable "name" {
  description = "Name, var.app_name-var.comp if blank"
  default     = ""
}

variable "report_build_status" {
  description = "Report status of build start and finish to source provider"
  default     = true
}

variable "subnet_ids" {
  description = "VPC subnet ids"
  type        = list(any)
  default     = []
}

variable "security_group_ids" {
  description = "Security group ids"
  type        = list(any)
  default     = []
}

variable "vpc_id" {
  description = "VPC id"
  default     = null
}
