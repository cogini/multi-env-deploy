# AWS Elasticache memcached
#
# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//elasticache-memcached"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "sg" {
#   config_path = "../sg-memcached-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#
#   subnet_group_name = dependency.vpc.outputs.elasticache_subnet_group
#   security_group_ids = [dependency.sg.outputs.security_group_id]
#   dns_domain = dependency.vpc.outputs.private_dns_domain
#   dns_zone_id = dependency.vpc.outputs.private_dns_zone_id
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

resource "aws_sns_topic" "this" {
  name = var.sns_topic_name != "" ? var.sns_topic_name : "${local.name}-${var.engine}"
}

# https://www.terraform.io/docs/providers/aws/r/elasticache_cluster.html
resource "aws_elasticache_cluster" "this" {
  cluster_id           = local.name
  engine               = var.engine
  engine_version       = var.engine_version
  maintenance_window   = var.maintenance_window
  node_type            = var.instance_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name

  subnet_group_name    = var.subnet_group_name
  security_group_ids   = var.security_group_ids

  apply_immediately = var.apply_immediately

  az_mode = var.az_mode

  notification_topic_arn = aws_sns_topic.this.arn

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

# CloudWatch resources
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "alarm${local.name}${var.engine}CacheClusterCPUUtilization"
  alarm_description   = "${var.engine} cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.this.id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  alarm_name          = "alarm${local.name}${var.engine}CacheClusterFreeableMemory"
  alarm_description   = "${var.engine} cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.this.id
  }

  alarm_actions = [aws_sns_topic.this.arn]
}

resource "aws_route53_record" "this" {
  zone_id = var.dns_zone_id
  name    = "${var.engine}.${var.comp}.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_elasticache_cluster.this.memcached.endpoint]
}
