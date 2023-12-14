output "eni_id" {
  description = "ID of the ENI for the NAT instance"
  value       = module.nat.eni_id
}

output "eni_private_ip" {
  description = "Private IP of the ENI for the NAT instance"
  value       = module.nat.eni_private_ip	
}

output "iam_role_name" {
  description = "Name of the IAM role for the NAT instance"
  value       = module.nat.iam_role_name
}

output "sg_id" {
  description = "ID of the security group of the NAT instance"
  value       = module.nat.sg_id
}
