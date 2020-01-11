output "key_arn" {
  value = aws_kms_key.default.arn
}

output "key_id" {
  value = aws_kms_key.default.key_id
}
