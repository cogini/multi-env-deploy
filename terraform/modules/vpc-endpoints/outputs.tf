# VPC Endpoints
# output "vpc_endpoint_s3_id" {
#   description = "The ID of VPC endpoint for S3"
#   value       = module.vpc.vpc_endpoint_s3_id
# }

# output "vpc_endpoint_dynamodb_id" {
#   description = "The ID of VPC endpoint for DynamoDB"
#   value       = module.vpc.vpc_endpoint_dynamodb_id
# }

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
