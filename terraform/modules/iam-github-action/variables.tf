variable "comp" {
  description = "Component"
}

variable "aws_account_id" {
  description = "AWS account id"
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  default     = ""
}

variable "name" {
  description = "Role name"
  default     = ""
}

variable "sub" {
  description = "GitHub repo allowed access, e.g. repo:cogini/*"
}

variable "s3_buckets" {
  description = "S3 buckets to sync"
  type        = list(any)
  default     = []
}

variable "enable_cloudfront" {
  description = "Enable CloudFront invalidation"
  default = false
}

variable "ecr_arn" {
  description = "ARN of ECR repository"
  default = ""
}

variable "ecs" {
  description = "ECS config"
  type = map(string)
  default = null
}

variable "codebuild_project_name" {
  description = "Name of CodeBuild project"
  default = ""
}

# variable "enable_codedeploy" {
#   description = "Enable CodeDeploy"
#   default = false
# }

# variable "codedeploy_name" {
#   description = "Common name for CodeDeploy components"
#   default = ""
# }

# variable "codedeploy_deploymentgroup_name" {
#   description = "CodeDeploy deployment group name"
#   default = ""
# }

# variable "codedeploy_deploymentconfig_name" {
#   description = "CodeDeploy deployment config name"
#   default = ""
# }

# variable "codedeploy_application_name" {
#   description = "CodeDeploy application name"
#   default = ""
# }

# variable "codedeploy_bucket" {
#   description = "CodeDeploy bucket"
#   default = ""
# }
