variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "name" {
  description = "Name, app_name-comp if blank"
  default     = ""
}

variable "vpc_id" {
  description = "VPC id"
}

variable "ingress_ports" {
  description = "Allow traffic from anyone on these ports"
  type        = list(number)
  default     = []
}

variable "ingress_protocols" {
  description = "Specify protocol for ingress_ports"
  type        = list(string)
  default     = ["tcp"]
}

variable "custom_ports" {
  description = "Allow traffic from anyone on these ports"
  type        = list(number)
  default     = []
}

variable "custom_protocols" {
  description = "Specify protocol for ingress_ports"
  type        = list(string)
  default     = ["tcp"]
}

variable "custom_cidr_blocks" {
  description = "Specify protocol for ingress_ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_ports" {
  description = "Ports that the application listens on"
  type        = list(number)
  default     = [80, 443]
}

variable "app_sources" {
  description = "Security group module names which can access app ports, e.g. lb-public, bastion, devops, prometheus"
  type        = list(string)
  default     = []
}

variable "prometheus_ports" {
  description = "Prometheus monitoring ports"
  type        = list(number)
  default     = [9100]
}

variable "prometheus_sources" {
  description = "Security group module names which can access prometheus ports, e.g. prometheus"
  type        = list(string)
  default     = []
}

variable "ssh_ports" {
  description = "Ports for ssh"
  type        = list(number)
  default     = [22]
}

variable "ssh_sources" {
  description = "Security group module names which can access ssh port, e.g. bastion"
  type        = list(string)
  default     = []
}

variable "icmp_sources" {
  description = "Security group module names which can access icmp (ping), e.g. bastion"
  type        = list(string)
  default     = []
}

variable "allow_self" {
  description = "Allow instances in this security group to communicate with each other"
  default     = false
}
