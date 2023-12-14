output "arn" {
  description = "The ARN of the listener rule"
  value       = aws_lb_listener.https.*.arn
}
