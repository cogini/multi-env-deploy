variable "enabled" {
  description = "Enabled"
  default     = true
}

variable "image_id" {
  description = "AMI of NAT instance, default latest Amazon Linux 2"
  default     = null
}

variable "instance_types" {
  description = "AMI of NAT instance, default latest Amazon Linux 2"
  type        = list(string)
  default     = ["t4g.nano"]
}

variable "key_name" {
  description = "Name of key pair"
  type        = string
  default     = null
}

variable "name" {
  description = "Name"
  default     = ""
}

variable "private_route_table_ids" {
  description = "Private route table ids"
  type        = list(string)
  default     = []
}

variable "public_subnet" {
  description = "Subnet where NAT instance is created"
}

variable "private_subnets_cidr_blocks" {
  description = "Subnets which should use NAT"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "vpc_id"
}
