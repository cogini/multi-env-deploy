output "launch_template_arn" {
  description = "Launch template arn"
  value       = aws_launch_template.this.arn
}

output "launch_template_id" {
  description = "Launch template id"
  value       = aws_launch_template.this.id
}

output "launch_template_default_version" {
  description = "Launch template default version"
  value       = aws_launch_template.this.default_version
}

output "launch_template_latest_version" {
  description = "Launch template latest version"
  value       = aws_launch_template.this.latest_version
}
