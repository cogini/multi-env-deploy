variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Service name, var.app_name-var.comp if empty"
  default     = ""
}

variable "xray" {
  description = "Add a sidecar for AWS X-Ray daemon"
  type        = bool
  default     = false
}

variable "xray_image" {
  description = "Image for X-Ray daemon"
  # default     = "123456789012.dkr.ecr.us-east-2.amazonaws.com/xray-daemon"
  default     = "amazon/aws-xray-daemon"
}

variable "image" {
  type        = string
  description = "The image used to start the container."
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = [
    {
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }
  ]
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps"
  default     = null
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "The secrets to pass to the container. This is a list of maps"
  default     = []
}

variable "cloudwatch_logs_create_group" {
  description = "Create CloudWatch Logs group"
  default     = true
}

variable "ssm_ps_param_prefix" {
  description = "Prefix for SSM Parameter Store parameters, default env/org/app/comp"
  default     = ""
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
variable "task_role_arn" {
  description = "IAM task role, similar to instance profile"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "IAM service role for container agent and the Docker daemon"
  type        = string
  default     = null
}

variable "network_mode" {
  description = "Docker networking mode for containers in task: none, bridge, awsvpc, or host"
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
  default     = "awsvpc"
}

variable "ipc_mode" {
  description = "IPC resource namespace for containers in task: host, task, or none"
  # Not supported for FARGATE launch type
  type        = string
  default     = null
}

variable "pid_mode" {
  description = "Process namespace for containers the task: host or task"
  # Not supported for FARGATE launch type
  type        = string
  default     = null
}

variable "cpu" {
  description = "Total number of cpu units used by task: 128 to 10240"
  # Required for FARGATE launch type
  type        = number
  default     = null
}

variable "container_cpu" {
  description = "Total number of cpu units used by task: 128 to 10240"
  # Required for FARGATE launch type
  type        = number
  default     = null
}

variable "memory" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type        = number
  default     = null
}

variable "container_memory" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type        = number
  default     = null
}


variable "memory_reservation" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type        = number
  default     = null
}

variable "requires_compatibilities" {
  description = "Launch types required by task: EC2 or FARGATE"
  default     = ["FARGATE"]
}

variable "volume" {
  description = "List of volume blocks"
  type        = list
  default     = []
}

variable "placement_constraints" {
  description = "Set of placement constraints rules during task placement, max 10"
  type        = list
  # Not supported for FARGATE launch type
  default     = []
}

variable "proxy_configuration" {
  description = "App Mesh proxy configuration details"
  type        = map
  default     = null
}
