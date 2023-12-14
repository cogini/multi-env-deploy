variable "description" {
  description = "Description"
  type = string
  default = null
}

variable "name" {
  description = "DNS namespace"
  default = ""
}

variable "vpc_id" {
  description = "VPC id"
}
