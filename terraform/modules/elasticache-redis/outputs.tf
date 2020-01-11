output "cluster_id" {
  value = aws_elasticache_cluster.this.cluster_id
}

output "cache_nodes" {
  value = aws_elasticache_cluster.this.cache_nodes
}

output "notification_topic_arn" {
  value = aws_sns_topic.this.arn
}
