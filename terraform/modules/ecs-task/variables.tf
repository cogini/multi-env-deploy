variable "comp" {
  description = "App component name, e.g. app, worker"
}

variable "name" {
  description = "Service name, app_name-comp if empty"
  default     = ""
}

variable "container_name" {
  description = "Container name, app_name-comp if empty"
  default     = ""
}

variable "service_name" {
  description = "Service name, name if empty"
  default     = ""
}

variable "family_name" {
  description = "Family name, name if empty"
  default     = ""
}

variable "command" {
  type        = list(string)
  description = "Command"
  default     = null
}

variable "entrypoint" {
  type        = list(string)
  description = "Entrypoint"
  default     = null
}

variable "xray" {
  description = "Add a sidecar for AWS X-Ray daemon"
  type        = bool
  default     = false
}

variable "xray_image" {
  description = "Image for X-Ray daemon"
  # default     = "123456789012.dkr.ecr.us-east-2.amazonaws.com/xray-daemon"
  default = "amazon/aws-xray-daemon"
}

variable "image" {
  type        = string
  description = "Image used to start container"
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "Port mappings to configure for container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

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
  description = "Environment variables to pass to container"
  default     = null
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Secrets to pass to container. This is a list of maps"
  default     = []
}

# variable "log_configuration" {
#   description = "Log configuration"
#   type = object({
#     logDriver = string
#     options   = optional(map(string))
#     secretOptions = optional(list(object({
#       name      = string
#       valueFrom = string
#     })))
#   })
# 
#   default     = null
# }

variable "awslogs_group" {
  description = "awslogs-group"
  default     = ""
}

variable "awslogs_stream_prefix" {
  description = "awslogs-stream-prefix"
  default     = ""
}

variable "awslogs_create_group" {
  description = "awslogs-create-group"
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
  default = "awsvpc"
}

variable "ipc_mode" {
  description = "IPC resource namespace for containers in task: host, task, or none"
  # Not supported for FARGATE launch type
  type    = string
  default = null
}

variable "pid_mode" {
  description = "Process namespace for containers the task: host or task"
  # Not supported for FARGATE launch type
  type    = string
  default = null
}

variable "cpu" {
  description = "Total number of cpu units used by task: 128 to 10240"
  # Required for FARGATE launch type
  type    = number
  default = null
}

variable "container_cpu" {
  description = "Total number of cpu units used by task: 128 to 10240"
  # Required for FARGATE launch type
  type    = number
  default = null
}

variable "memory" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type    = number
  default = null
}

variable "container_memory" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type    = number
  default = null
}

variable "memory_reservation" {
  description = "Amount in MiB of memory used by task"
  # Required for FARGATE launch type
  type    = number
  default = null
}

variable "requires_compatibilities" {
  description = "Launch types required by task: EC2 or FARGATE"
  default     = ["FARGATE"]
}

variable "volume" {
  description = "List of volume blocks"
  type        = list(any)
  default     = []
}

variable "placement_constraints" {
  description = "Set of placement constraints rules during task placement, max 10"
  type        = list(any)
  # Not supported for FARGATE launch type
  default = []
}

variable "proxy_configuration" {
  description = "App Mesh proxy configuration details"
  type        = map(any)
  default     = null
}
