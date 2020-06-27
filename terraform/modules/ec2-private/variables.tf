variable "comp" {
  description = "Name of component: bastion, app, worker, etc."
}

variable "name" {
  description = "Name tag of instance, var.app_name-var.comp if empty"
  default = ""
}

variable "host_name" {
  description = "DNS name, var.name if empty"
  default = ""
}

variable "dns_domain" {
  description = "DNS domain (zone)"
}

variable "dns_zone_id" {
  description = "Route53 DNS zone id"
}

variable "instance_profile_name" {
  description = "Instance profile"
  default = ""
}

variable "subnet_ids" {
  description = "VPC subnet ids"
  type = list
}

variable "security_group_ids" {
  description = "Security group ids"
  type = list
}

variable "availability_zones" {
  description = "Availaibility zones"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of instances to create. If 0, will create one per subnet"
  default     = 1
}

variable "ami" {
  description = "ID of AMI to use for the instance"
}

variable "instance_type" {
  description = "Type of instance to start"
  default     = "t3.micro"
}

variable "keypair_name" {
  description = "Name of keypair for the instance"
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

variable "ebs_optimized" {
  description = "For EBS optimized instances"
  default     = false
}

variable "root_volume_size" {
  description = "Size of root block device (in GiB)"
  default     = 8
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

variable "create_dns" {
  description = "Create DNS records for instance"
  default     = true
}

variable "dns_ttl" {
  description = "DNS record time to live"
  default     = 60
}
