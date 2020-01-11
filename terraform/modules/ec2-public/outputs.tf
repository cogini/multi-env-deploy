output "id" {
  description = "List of instance ids"
  value       = aws_instance.this[*].id
}

# output "arn" {
#   description = "List of instance arns"
#   value       = aws_instance.this.*.arn
# }

output "availability_zone" {
  description = "List of instance availability zones"
  value       = aws_instance.this[*].availability_zone
}

output "placement_group" {
  description = "List of instance placement groups"
  value       = aws_instance.this[*].placement_group
}

output "key_name" {
  description = "List of instance key names"
  value       = aws_instance.this[*].key_name
}

output "public_dns" {
  description = "List of instance public DNS names"
  value       = aws_instance.this[*].public_dns
}

output "public_ip" {
  description = "List of instance public IP addresses"
  value       = aws_instance.this[*].public_ip
}

# output "network_interface_id" {
#   description = "List of instance network interface ids"
#   value       = aws_instance.this[*].network_interface_id
# }

output "primary_network_interface_id" {
  description = "List of instance primary network interface ids"
  value       = aws_instance.this[*].primary_network_interface_id
}

output "private_dns" {
  description = "List of instance private DNS names"
  value       = aws_instance.this[*].private_dns
}

output "private_ip" {
  description = "List of instance private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "security_groups" {
  description = "List of instance security groups"
  value       = aws_instance.this[*].security_groups
}

output "vpc_security_group_ids" {
  description = "List of instance vpc security group ids"
  value       = aws_instance.this[*].vpc_security_group_ids
}

output "subnet_id" {
  description = "List of instance subnet ids"
  value       = aws_instance.this[*].subnet_id
}

# output "credit_specification" {
#   description = "List of instance credit specifications"
#   value       = aws_instance.this.*.credit_specification
# }

output "iam_instance_profile_name" {
  description = "List of instance IAM instance profile names"
  value       = aws_instance.this[*].iam_instance_profile
}
