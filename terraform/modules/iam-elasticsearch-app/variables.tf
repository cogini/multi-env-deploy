variable "comp" {
  description = "Component, e.g. app, worker"
}

variable "name" {
  description = "Name of the Elasticsearch component, comp if blank"
  default     = ""
}

variable "domain_name" {
  description = "Name of the Elasticsearch domain"
}

variable "domain_arn" {
  description = "ARN Elasticsearch domain"
}
