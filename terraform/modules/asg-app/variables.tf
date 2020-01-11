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

variable "min_size" {
  description = "Minimum number of instances running in ASG"
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances running in ASG"
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances running in ASG"
  default     = 1
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#waiting-for-capacity
variable "wait_for_capacity_timeout" {
  description = "Maximum duration to wait for ASG instances to be healthy. e.g. 5m or 0 to disable, default 10m"
  default     = null
}

variable "wait_for_elb_capacity" {
  description = "Wait for this number of healthy instances in all attached load balancers on both create and update operations. (Takes precedence over min_elb_capacity) "
  default     = null
}

variable "min_elb_capacity" {
  description = "Wait for at least the requested number of instances to show up InService in all attached ELBs"
  default     = null
}

variable "target_group_arns" {
  description = "Target Group ARNs"
  type = list
  default = []
}

variable "default_cooldown" {
  description = "Time in seconds after a scaling activity completes before another can start"
  default     = 60
}

variable "launch_template_id" {
  description = "Launch Template id"
}

variable "launch_template_version" {
  description = "Launch Template version: $Latest, or $Default"
  default = "$Latest"
}

variable "termination_policies" {
  description = "List of policies to decide how the instances in the auto scale group should be terminated"
  type = list(string)
  default = ["OldestLaunchTemplate", "Default"]
}

variable "on_demand_allocation_strategy" {
  description = "Strategy to use when launching on-demand instances. Valid values: prioritized. Default: prioritized."
  default = null
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances: default 0"
  default = null
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity. Default: 100."
  default = null
}

variable "spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools. Valid values: lowest-price, capacity-optimized. Default: lowest-price."
  default = null
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. Default: 2."
  default = null
}

variable "spot_max_price" {
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances. Default: an empty string which means the on-demand price."
  default = null
}

variable "subnets" {
  description = "Subnet ids"
  type = list
}

variable "health_check_type" {
  description = "Type of health check: EC2 or ELB"
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance comes into service before checking health, default 300"
  default     = null
}

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
