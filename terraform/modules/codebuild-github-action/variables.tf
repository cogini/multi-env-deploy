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

variable "codebuild_image" {
  description = "ECR image URL or predefined image name"
  # default     = "ubuntu:bionic"
  # default     = "centos:7"
}

variable "buildspec" {
  description = "Buildspec file name, e.g. subdir/buildspec.yml"
  default     = "buildspec.yml"
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
  default     = null
}

variable "codebuild_service_role_arn" {
  description = "CodeBuild IAM service role ARN"
}
variable "build_timeout" {
  description = "Build timeout in minutes"
  default     = null
}
