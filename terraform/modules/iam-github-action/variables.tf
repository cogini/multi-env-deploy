variable "comp" {
  description = "Component"
}

variable "aws_account_id" {
  description = "AWS account id"
  default     = ""
}

variable "kms_default_key" {
  description = "Enable access to default KMS key"
  default     = false
}

variable "kms_key_id" {
  description = "KMS key id"
  default     = null
}

variable "kms_key_aliases" {
  description = "KMS key id"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Role name"
  default     = ""
}

variable "sub" {
  description = "GitHub repo allowed access, e.g. repo:cogini/*"
  type        = string
  default     = null
}

variable "subs" {
  description = "GitHub repo allowed access, e.g. repo:cogini/*"
  type        = list(string)
  default     = null
}

variable "s3_buckets" {
  description = "S3 buckets to sync"
  type        = list(any)
  default     = []
}

variable "enable_cloudfront" {
  description = "Enable CloudFront invalidation"
  default     = false
}

variable "ecr_arns" {
  description = "ARNs of ECR repository"
  type        = set(string)
  default     = []
}

variable "ec2" {
  description = "EC2 config"
  type        = list(map(string))
  default     = []
}

variable "ecs" {
  description = "ECS config"
  type        = list(map(string))
  default     = []
}

variable "codebuild_project_name" {
  description = "Name of CodeBuild project"
  default     = ""
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
