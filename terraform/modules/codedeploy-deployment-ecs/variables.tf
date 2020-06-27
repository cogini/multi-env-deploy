variable "comp" {
  description = "Part of the app, e.g. app, worker"
}

variable "name" {
  description = "Name, var.app_name-var.comp-ecs if blank"
  default = ""
}

variable "deploy_hook" {
  description = "Tag used by deployment group to find target ASG, var.name if empty"
  default = ""
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
  default     = null
}

# ECS
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default = null
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = null
}

variable "target_group_names" {
  description = "ECS target group names"
  type        = list(string)
  default     = []
}

variable "listener_arns" {
  description = "ECS load balancer listener ARNs"
  type        = list(string)
  default     = []
}

variable "codedeploy_app_name" {
  description = "CodeDeploy app name"
  type        = string
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy IAM service role"
}

variable "deployment_type" {
  description = "BLUE_GREEN or IN_PLACE"
  default     = null
}

variable "deployment_option" {
  description = "WITH_TRAFFIC_CONTROL or WITHOUT_TRAFFIC_CONTROL"
  default     = null
}

variable "deployment_config_name" {
  description = "Deployment config name"
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

# Blue/Green
variable "deployment_ready_option_action_on_timeout" {
  description = "When to reroute traffic from original environment to replacement environment: CONTINUE_DEPLOYMENT (auto) or STOP_DEPLOYMENT (manual)"
  default     = "STOP_DEPLOYMENT"
}

# Blue/Green
variable "deployment_ready_option_wait_time_in_minutes" {
  description = "Minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually. Applies only when action is STOP_DEPLOYMENT"
  default     = 5
}

# Blue/Green
variable "provisioning_action" {
  description = "Method used to add instances to a replacement environment: DISCOVER_EXISTING or COPY_AUTO_SCALING_GROUP"
  default     = null
}

# Blue/Green
variable "termination_action" {
  description = "Action to take on instances in the original environment after a successful blue/green deployment: TERMINATE or KEEP_ALIVE"
  default     = "TERMINATE"
}

# Blue/Green
variable "termination_wait_time_in_minutes" {
  description = "How long to wait to terminate the instances after a successful deployment"
  default     = 5
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
