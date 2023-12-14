variable "name" {
  description = "Name tag of cluster, app_name if empty"
  default     = ""
}

variable "capacity_providers" {
  description = "List of short names capacity providers: FARGATE, FARGATE_SPOT and/or name"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "List of objects"
  type        = list(any)
  default     = []
}

variable "container_insights" {
  description = "Whether to enable container_insights: enabled or disabled"
  default     = null
}

variable "service_discovery_namespace" {
  description = "ARN of default service discovery namespace"
  type        = string
  default     = null
}
