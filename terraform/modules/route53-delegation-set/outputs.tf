output "id" {
  description = "Delegation set id"
  value       = aws_route53_delegation_set.main.id
}

output "name_servers" {
  description = "Delegation set name servers"
  value       = aws_route53_delegation_set.main.name_servers
}
