variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name, app_name-comp if empty"
  default     = ""
}

# Launch Template options
variable "instance_profile_name" {
  description = "Instance Profile name"
}

variable "security_group_ids" {
  description = "Security group ids"
  type = list
}

variable "image_id" {
  description = "EC2 image ID (AMI) to launch"
}

variable "instance_type" {
  description = "The type of instance to launch"
  default     = "t2.micro"
}

variable "user_data" {
  description = "The Base64-encoded user data to provide when launching the instance"
  default     = ""
}

variable "keypair_name" {
  description = "Name of ssh keypair"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance: stop or terminate"
  default     = "terminate"
}

variable "block_device_mappings" {
  description = "Volumes to attach to the instance besides the volumes specified by the AMI"
  type        = list(string)
  default     = []
}

variable "capacity_reservation_specification" {
  description = "Targeting for EC2 capacity reservations"
  type        = list(string)
  default     = []
}

variable "credit_specification" {
  description = "Customize the credit specification of the instance"
  type        = list(string)
  default     = []
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance"
  type        = list(string)
  default     = []
}

variable "ebs_optimized" {
  description = "Enable EBS optimized disk"
  default     = false
}
