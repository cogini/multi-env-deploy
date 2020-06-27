variable "vpc_id" {
  description = "The ID of the VPC to assoicate with"
  default     = ""
}

variable "vpc_vgw_id" {
  description = "The ID of Virtual Private Gateway to associate with"
  default     = ""
}

variable "vpc_cgw_ids" {
  description = "The IDs of Customer Gateways"
  default     = ""
}

variable "vpc_private_route_table_ids" {
  description = "The route table ids of the associated VPC"
  type        = list(string)
  default     = []
}
