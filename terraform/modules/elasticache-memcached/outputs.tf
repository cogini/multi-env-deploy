output "cluster_id" {
  value = aws_elasticache_cluster.this.id
}

output "cache_nodes" {
  value = aws_elasticache_cluster.this.cache_nodes
}

output "configuration_endpoint" {
  value = aws_elasticache_cluster.this.configuration_endpoint
}

output "port" {
  value = aws_elasticache_cluster.this.port
}

output "cluster_address" {
  value = aws_elasticache_cluster.this.cluster_address
}

output "notification_topic_arn" {
  value = aws_sns_topic.this.arn
}
