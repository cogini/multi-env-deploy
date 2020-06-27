variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, var.app_name-var.comp-ec2 if blank"
  default = ""
}

variable "codedeploy_app_name" {
  description = "CodeDeploy app name"
}

variable "trigger_name" {
  description = "Name of trigger, var.name if blank"
  default     = ""
}

variable "trigger_target_arn" {
  description = "Trigger SNS topic"
  default     = ""
}

variable "trigger_events" {
  description = "DeploymentStart, DeploymentSuccess, DeploymentFailure, DeploymentStop, DeploymentRollback, InstanceStart, InstanceSuccess, InstanceFailure."
  default     = ["DeploymentFailure"]
  type        = list(string)
}

#variable "ec2_tag_set" {
#  description = "Set of tags used to find instances to deploy to (EC2)"
#  default     = []
#}

variable "ec2_tag_filter" {
  description = "Tags used to find instances to deploy to (EC2)"
  type        = list
  default     = []
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy IAM service role"
}

variable "deployment_type" {
  description = "BLUE_GREEN or IN_PLACE"
  # default     = null
  default     = "IN_PLACE"
}

variable "deployment_option" {
  description = "WITH_TRAFFIC_CONTROL or WITHOUT_TRAFFIC_CONTROL"
  # default     = null
  default     = "WITHOUT_TRAFFIC_CONTROL"
}

variable "on_premises_instance_tag_filter" {
  description = "Tags used to find instances to deploy to (on-premises)"
  type        = list
  default     = []
}

variable "deployment_config_name" {
  description = "Deployment config name"
  default     = "CodeDeployDefault.OneAtATime"
}

# https://www.terraform.io/docs/providers/aws/r/codedeploy_deployment_group.html#auto-rollback-configuration
variable "auto_rollback_configuration_enabled" {
  description = "Whether to enable auto rollback"
  default     = true
}

variable "auto_rollback_configuration_events" {
  description = " Event type or types that trigger a rollback. DEPLOYMENT_FAILURE or DEPLOYMENT_STOP_ON_ALARM"
  default     = ["DEPLOYMENT_FAILURE"]
}

variable "alarm_configuration" {
  description = "Stop a deployment when a CloudWatch alarm detects that a metric has fallen below or exceeded a defined threshold"
  type        = list(string)
  default     = []
}
