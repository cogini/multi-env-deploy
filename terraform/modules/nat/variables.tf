variable "enabled" {
  description = "Enabled"
  default     = true
}

variable "name" {
  description = "Name"
  default     = ""
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "public_subnet" {
  description = "Subnet where NAT instance is created"
}

variable "private_subnets_cidr_blocks" {
  description = "Subnets which should use NAT"
  type        = list(string)
  default     = []
}

variable "private_route_table_ids" {
  description = "Private route table ids"
  type        = list(string)
  default     = []
}
