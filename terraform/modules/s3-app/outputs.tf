# App assets such as CSS and JS published via CDN

output "buckets" {
  description = "Bucket outputs"
  value =  aws_s3_bucket.buckets
}
