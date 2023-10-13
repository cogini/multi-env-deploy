output "bucket" {
  description = "Bucket"
  value       = aws_s3_bucket.this
}

output "id" {
  description = "Bucket"
  value       = aws_s3_bucket.this.id
}
