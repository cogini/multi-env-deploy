output "arn" {
  value = aws_codestarconnections_connection.this.arn
}

output "id" {
  value = aws_codestarconnections_connection.this.id
}

output "status" {
  value = aws_codestarconnections_connection.this.connection_status
}
