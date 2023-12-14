variable "ami" {
  description = "ID of AMI to use for the instance"
  default     = ""
}

variable "ami_filter" {
  description = "Filter to find AMI"
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
}

variable "availability_zones" {
  description = "Availaibility zones"
  type        = list(string)
  default     = []
}

variable "comp" {
  description = "Name of component: bastion, app, worker, etc."
}

variable "create_dns" {
  description = "Create DNS records for instance"
  default     = false
}

variable "dns_domain" {
  description = "DNS domain (zone)"
  default     = ""
}

variable "dns_ttl" {
  description = "DNS record time to live"
  default     = 60
}

variable "dns_zone_id" {
  description = "Route53 DNS zone id"
  default     = ""
}

variable "ebs_optimized" {
  description = "For EBS optimized instances"
  default     = false
}

variable "host_name" {
  description = "DNS name, var.name if empty"
  default     = ""
}

variable "instance_count" {
  description = "Number of instances to create. If 0, will create one per subnet"
  default     = 1
}

variable "instance_type" {
  description = "Type of instance to start"
  default     = "t3.micro"
}

variable "instance_profile_name" {
  description = "Instance profile"
  default     = ""
}

variable "keypair_name" {
  description = "Name of keypair for the instance"
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default     = ""
}

variable "subnet_ids" {
  description = "VPC subnet ids"
  type        = list(any)
}

variable "security_group_ids" {
  description = "Security group ids"
  type        = list(any)
}

variable "disable_api_termination" {
  description = "If true, enable EC2 Instance Termination Protection"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  default     = "stop"
}

variable "monitoring" {
  description = "Enable detailed monitoring for instance"
  default     = false
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  default     = ""
}

variable "root_volume_size" {
  description = "Size of root block device (in GiB)"
  default     = 8
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}
