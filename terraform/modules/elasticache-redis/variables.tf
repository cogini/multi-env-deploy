variable "comp" {
  description = "Application component, e.g. app, worker"
}

variable "name" {
  description = "Name of the instance, var.app_name-var.comp if blank"
  default     = ""
}

variable "subnet_group_name" {
  description = "VPC subnet group"
}

variable "security_group_ids" {
  description = "Security group ids"
  type        = list(any)
}

variable "dns_domain" {
  description = "DNS domain"
}

variable "dns_zone_id" {
  description = "DNS zone_id"
}


variable "engine" {
  description = "component of the system, e.g. app, worker"
  default     = "redis"
}

variable "engine_version" {
  description = "Version of Redis or Memcache engine"
  # aws elasticache describe-cache-engine-versions --engine redis
  default = "5.0.4"
}

variable "maintenance_window" {
  description = "The weekly time range when maintenance is performed. Format ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). Minimum maintenance window is a 60 minute period."
  default     = "sun:02:30-sun:03:30"
}

# https://aws.amazon.com/elasticache/details/#Available_Cache_Node_Types
variable "instance_type" {
  description = "The compute and memory capacity of the nodes"
  default     = "cache.t2.micro"
}

variable "parameter_group_name" {
  description = "Name of parameter group"
  default     = "default.redis5.0"
}

variable "num_cache_nodes" {
  description = "Initial number of cache nodes in the cache cluster. 1 for Redis. Between 1 and 20 for memcached"
  default     = "1"
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "sns_topic_name" {
  description = "SNS topic name for alerts"
  default     = ""
}

variable "alarm_cpu_threshold_percent" {
  default = "75"
}

variable "alarm_memory_threshold_bytes" {
  # 10MB
  default = "10000000"
}
