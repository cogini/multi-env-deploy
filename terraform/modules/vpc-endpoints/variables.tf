variable "cidr_blocks" {
  description = "The CIDR block for the VPC"
  type = list(string)
  default = []
}

variable "create_ec2_instance_connect_endpoint" {
  description = "Whether to create EC2 Instance Connect Endpoint"
  default     = false
}

variable "endpoints" {
  description = "VPC encpoints"
  type        = map(map(any))
  default     = {}
}
