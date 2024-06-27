# variable "name" {
#   description = "Name to be used on all the resources as identifier"
#   default     = ""
# }

variable "availability_zones" {
  description = "Availaibility zones"
  type        = list(string)
  default     = []
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "dhcp_options_domain_name" {
  description = "DHCP domain name"
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "DHCP domain name servers"
  default     = ["127.0.0.1", "10.10.0.2"]
}

variable "enable_dhcp_options" {
  description = "Enable DHCP for VPC"
  default     = true
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
  # default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
  # default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
  # default = ["10.10.21.0/24", "10.10.22.0/24"]
}

variable "elasticache_subnets" {
  description = "A list of elasticache subnets"
  type        = list(string)
  default     = []
}

# Used to allow direct remote access to db
variable "create_database_subnet_group" {
  description = "Whether to create database subnet group"
  default     = false
}

# Used to allow direct remote access to db
variable "create_database_subnet_route_table" {
  description = "Whether to create database subnet route table"
  default     = false
}

# Used to allow direct remote access to db
variable "create_database_internet_gateway_route" {
  description = "Whether to create database internet gateway route"
  default     = false
}

variable "enable_nat_gateway" {
  description = "Provision NAT Gateways for each of your private networks"
  default     = false
}

variable "single_nat_gateway" {
  description = "Provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Provision a NAT Gateway per AZ"
  default     = false
}

variable "enable_vpn_gateway" {
  description = "To create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN"
  default     = 64620
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = map(map(any))
  default     = {}
}

#variable "enable_dynamodb_endpoint" {
#  description = "Provision a DynamoDB endpoint to the VPC"
#  default     = false
#}

#variable "enable_s3_endpoint" {
#  description = "Provision an S3 endpoint to the VPC"
#  default     = false
#}

# variable "map_public_ip_on_launch" {
#   description = "Should be false if you do not want to auto-assign public IP on launch"
#   default     = true
# }

# variable "private_propagating_vgws" {
#   description = "A list of VGWs the private route table should propagate"
#   default     = []
# }

# variable "public_propagating_vgws" {
#   description = "A list of VGWs the public route table should propagate"
#   default     = []
# }

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  default     = {}
}

variable "elasticache_subnet_tags" {
  description = "Additional tags for the elasticache subnets"
  default     = {}
}
