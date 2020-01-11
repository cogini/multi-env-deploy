variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, var.app_name-var.comp if blank"
  default = ""
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy IAM service role"
}

variable "codedeploy_app_name" {
  description = "CodeDeploy app name"
}

variable "deployment_group_name" {
  description = "Name of the deployment group, var.name if blank"
  default     = ""
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

variable "deploy_hook" {
  description = "Tag used by deployment group to find target ASG, var.name if empty"
  default = ""
}

variable "target_group_name" {
  description = "Target group name"
}

variable "deployment_config_name" {
  description = "Deployment config name"
  default     = "CodeDeployDefault.ECSAllAtOnce"
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

variable "deployment_ready_option_action_on_timeout" {
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment"
  default     = "STOP_DEPLOYMENT" # CONTINUE_DEPLOYMENT
}

variable "deployment_ready_option_wait_time_in_minutes" {
  description = "Minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually. Applies only when action is STOP_DEPLOYMENT"
  default     = 5
}

variable "termination_wait_time_in_minutes" {
  description = "How long to wait to terminate the instances after a successful deployment"
  default     = 5
}
