variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default     = ""
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy"
  type        = list(any)
  default     = []
}

variable "cluster" {
  description = "ECS cluster ARN"
  type        = string
  default     = null
}

variable "deployment_controller_type" {
  description = "Deployment controller type: CODE_DEPLOY or ECS. Default: ECS"
  type        = string
  default     = null
}

variable "deployment_maximum_percent" {
  description = "Upper limit (percentage of desired_count) of running tasks that can be running in a service during a deployment"
  # Default 200% for REPLICA, 100% for DAEMON
  default = null
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (pct of desired_count) of running tasks that must remain running and healthy in a service during a deployment"
  # Default 100%, 0% for DAEMON
  default = null
}

variable "desired_count" {
  description = "Number of instances of the task to place and keep running"
  # Default 0
  default = null
}

variable "family_name" {
  description = "Name tag task definition family, name if blank"
  default     = ""
}

variable "force_new_deployment" {
  description = "Force new task deployment of the service"
  default     = null
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-using-tags.html#tag-resources-for-billing
variable "enable_ecs_managed_tags" {
  description = "Enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = null
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  # Default 0
  default = null
}

variable "iam_role" {
  description = "ARN of IAM role that allows Amazon ECS to make calls to load balancer on your behalf"
  # This parameter is required if you are using a load balancer with your
  # service, but only if your task definition does not use the awsvpc network
  # mode. If using awsvpc network mode, do not specify this role.
  # If your account has already created the Amazon ECS service-linked role,
  # that role is used by default for your service unless you specify a role
  # here.
  type    = string
  default = null
}

variable "launch_type" {
  description = "Launch type: EC2 or FARGATE"
  # Default EC2
  default = null
}

variable "load_balancer" {
  description = "List of load balancer configs"
  type        = list(any)
  default     = []
}

variable "network_configuration" {
  description = "Network configuration"
  type        = object({ subnets = list(string), security_groups = list(string), assign_public_ip = bool })
  default     = null
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules taken into consideration during task placement"
  type        = list(any)
  default     = []
}

variable "placement_constraints" {
  description = "Rules taken into consideration during task placement"
  type        = list(string)
  # Not supported for FARGATE
  default = []
}

variable "platform_version" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE. Defaults to LATEST"
  type        = string
  default     = null
}

variable "propagate_tags" {
  description = "Whether to propagate tags from task definition or service to tasks: SERVICE or TASK_DEFINITION"
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy: REPLICA or DAEMON"
  # Default REPLICA. Fargate tasks do not support DAEMON."
  type    = string
  default = null
}

# https://www.terraform.io/docs/providers/aws/r/ecs_service.html#service_registries-1
variable "service_registries" {
  description = "Service discovery registries for the service"
  type        = map(any)
  default     = null
}

variable "task_definition" {
  description = "Family and revision (family:revision) or full ARN of task definition to run in service"
  type        = string
  default     = ""
}
