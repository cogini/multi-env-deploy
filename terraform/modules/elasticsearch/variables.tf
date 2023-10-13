variable "comp" {
  description = "Application component, e.g. app, worker"
}

variable "name" {
  description = "Name of the instance, var.app_name-var.comp if blank"
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(any)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(any)
}

variable "kms_key_id" {
  description = "KMS key id"
  default     = null
}

variable "cloudwatch_log_group" {
  description = "CloudWatch logs group, app_name-comp if empty"
  default     = ""
}

variable "elasticsearch_version" {
  description = "Elasticsearch version"
  default     = "6.3"
}

# cluster_config attributes
# http://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-supported-instance-types.html
# https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/sizing-domains.html#aes-bp-instances
# https://aws.amazon.com/elasticsearch-service/pricing/
variable "instance_type" {
  description = "Instance type of data nodes in the cluster"
  default     = "t2.small.elasticsearch"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  default     = 1
}

# http://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains.html#es-managedomains-dedicatedmasternodes
variable "dedicated_master_enabled" {
  description = "Indicates whether dedicated master nodes are enabled for the cluster"
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type of the dedicated master nodes in the cluster."
  default     = "m3.medium.elasticsearch"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes in the cluster."
  default     = 3
}

variable "zone_awareness_enabled" {
  description = "Indicates whether zone awareness is enabled."
  default     = false
}

# ebs_options attributes
variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain"
  default     = true
}

# http://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-ebs
variable "volume_type" {
  description = "EBS volume type attached to data nodes, standard (magnetic), gp2, io1"
  default     = "gp2"
}

variable "volume_size" {
  description = "EBS volume size attached to data nodes in GB. Required if ebs_enabled is true"
  default     = 10
}

variable "iops" {
  description = "EBS volume baseline I/O performance. Applicable only for the Provisioned IOPS EBS volume type"
  # default = 1000
  default = 0
}

# snapshot_options attributes
variable "automated_snapshot_start_hour" {
  description = "Hour during which the service takes an automated daily snapshot of the indices in the domain. UTC integer default 0 (midnight)"
  default     = 0
}

# variable "domain_name" {
#   description = "Elasticsearch domain name"
# }

# variable "access_policies" {
#   description = "IAM policy document specifying the access policies for the domain"
#   default     = ""
# }

# variable "advanced_options"  {
#   description = "Key-value string pairs to specify advanced configuration options."
#   type        = "map"
#   default     = ""
# }

variable "encrypt" {
  description = "Encrypt storage and node communications"
  default     = false
}

# vpc_options attributes
# variable "security_group_ids" {
#   description = "List of VPC Security Group IDs to be applied to the Elasticsearch domain endpoints. If omitted, the default Security Group for the VPC will be used."
#   default     = ""
# }
#
# variable "subnet_ids" {
#   description = "(Required) List of VPC Subnet IDs for the Elasticsearch domain endpoints to be created in."
#   default = ""
# }
