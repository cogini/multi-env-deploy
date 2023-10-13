# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = module.vpc.default_network_acl_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.vpc.elasticache_subnets
}

output "elasticache_subnet_group" {
  description = "ID of elasticache subnet group"
  value       = module.vpc.elasticache_subnet_group
}

output "subnets" {
  description = "Subnets as a map keyed by name"
  value = {
    "private"     = module.vpc.private_subnets
    "public"      = module.vpc.public_subnets
    "database"    = module.vpc.database_subnets
    "elasticache" = module.vpc.elasticache_subnets
  }
}

# Route tables
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

# VPN Gateway
output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = module.vpc.vgw_id
}

# Customer Gateway
output "cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value       = module.vpc.cgw_ids
}

# VPC Endpoints
# output "vpc_endpoint_s3_id" {
#   description = "The ID of VPC endpoint for S3"
#   value       = module.vpc.vpc_endpoint_s3_id
# }

# output "vpc_endpoint_dynamodb_id" {
#   description = "The ID of VPC endpoint for DynamoDB"
#   value       = module.vpc.vpc_endpoint_dynamodb_id
# }

output "private_dns_zone_id" {
  description = "Route53 zone_id for the private zone"
  value       = join("", aws_route53_zone.this.*.zone_id)
}

output "private_dns_domain" {
  description = "Route53 domain name for the private zone"
  value       = join("", aws_route53_zone.this.*.name)
}

output "private_dns_domain_nodot" {
  description = "Route53 domain name for the private zone"
  value       = replace(join("", aws_route53_zone.this.*.name), "/\\.$/", "")
}

# VPC endpoints
output "vpc_endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.vpc_endpoints.endpoints
}

output "vpc_endpoints_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.vpc_endpoints.security_group_arn
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group"
  value       = module.vpc_endpoints.security_group_id
}
