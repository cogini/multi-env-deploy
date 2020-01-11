variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default = ""
}

variable "deploy_hook" {
  description = "Tag used by deployment group to find current ASG, var.name if empty"
  default = ""
}


variable "target_group_arns" {
  description = "Target Group ARNs"
  type = list
  default = []
}

variable "subnets" {
  description = "Subnet ids"
  type = list
}

variable "launch_template_id" {
  description = "Launch Template id"
}

# ASG
variable "max_size" {
  description = "Maximum number of instances running in ASG"
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances running in ASG"
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances running in ASG"
  default     = 1
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#waiting-for-capacity
variable "wait_for_capacity_timeout" {
  description = "Maximum duration to wait for ASG instances to be healthy. e.g. 5m or 0 to disable"
  default     = null
}

variable "default_cooldown" {
  description = "Time in seconds after a scaling activity completes before another can start"
  default     = 60
}

variable "health_check_type" {
  description = "Type of health check: EC2 or ELB"
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance comes into service before checking health"
  default     = null
}

# variable "metrics_granularity" {
#   description = "Granularity to associate with the metrics to collect"
#   default     = null
# }

variable "enabled_metrics" {
  description = "List of metrics to collect"
  type        = list(string)
  default     = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate"
  default     = null
}

variable "extra_tags_list" {
  description = "Extra tags to attach, list of objects"
  default     = []
}
