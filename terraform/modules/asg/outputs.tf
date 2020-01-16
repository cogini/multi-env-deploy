output "autoscaling_group_name" {
  description = "ASG name"
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_id" {
  description = "ASG id"
  value       = aws_autoscaling_group.this.id
}

output "autoscaling_group_arn" {
  description = "ASG arn"
  value       = aws_autoscaling_group.this.arn
}

#output "autoscaling_group_availability_zones" {
#  description = "Autoscaling group availability zones"
#  value = "${aws_autoscaling_group.this.availability_zones}"
#}

output "autoscaling_group_min_size" {
  description = "ASG min size"
  value       = aws_autoscaling_group.this.min_size
}

output "autoscaling_group_max_size" {
  description = "ASG max size"
  value       = aws_autoscaling_group.this.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "ASG desired capacity"
  value       = aws_autoscaling_group.this.desired_capacity
}

output "autoscaling_group_health_check_grace_period" {
  description = "ASG health check grace period"
  value       = aws_autoscaling_group.this.health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "ASG health check type"
  value       = aws_autoscaling_group.this.health_check_type
}

# output "autoscaling_group_launch_configuration" {
#   description = "Autoscaling group launch_configuration"
#   value = "${aws_autoscaling_group.this.launch_configuration}"
# }

output "autoscaling_group_vpc_zone_identifier" {
  description = "ASG vpc_zone_identifier"
  value       = aws_autoscaling_group.this.vpc_zone_identifier
}

output "autoscaling_group_load_balancers" {
  description = "ASG load_balancers"
  value       = aws_autoscaling_group.this.load_balancers
}

output "autoscaling_group_target_group_arns" {
  description = "ASG target_group_arns"
  value       = aws_autoscaling_group.this.target_group_arns
}

# output "launch_configuration_name" {
#   description = "Launch configuration name"
#   value = aws_launch_configuration.this.name
# }
#
# output "launch_configuration_id" {
#   description = "Launch configuration id"
#   value = aws_launch_configuration.this.id
# }
