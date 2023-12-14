output "arn" {
  description = "ARN of app monitor"
  value = aws_rum_app_monitor.this.arn
}

output "id" {
  description = "CloudWatch RUM name as identifier"
  value = aws_rum_app_monitor.this.id
}

output "app_monitor_id" {
  description = "Unique identifier of app monitor"
  value = aws_rum_app_monitor.this.app_monitor_id
}

output "cw_log_group" {
  description = "Name of log group where copies are stored"
  value = aws_rum_app_monitor.this.cw_log_group
}
