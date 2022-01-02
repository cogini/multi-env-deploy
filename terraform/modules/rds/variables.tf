variable "comp" {
  description = "Component, e.g. app, worker"
}

variable "name" {
  description = "Name of the instance, var.app_name-var.comp if blank"
  default     = ""
}

# db.t2.micro instance class doesn't encryption, it requires at least db.t2.small
variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  default     = false
}


variable "engine" {
  description = "The database engine to use, postgres or mysql"
  type        = string
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "ca_cert_identifier" {
  description = "Identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections, 5432 for postgres, 3306 for mysql"
  type        = string
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
variable "instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"

  # default = 20
  default = 5
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'."
  default     = "gp2"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  default     = 0
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

# variable "final_snapshot_identifier" {
#   description = "The name of your final DB snapshot when this DB instance is deleted."
#   default     = false
# }

# variable "db_name" {
#   description = "The DB name to create. If omitted, no database is created initially"
# }

variable "rds_master_user" {
  description = "Username for the master DB user"
}

variable "rds_master_pass" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
}

variable "deletion_protection" {
  description = "Database Deletion Protection"
  default     = true
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  default     = false
}

variable "monitoring_interval" {
  description = "Seconds between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "create_monitoring_role" {
  description = "Whether to create monitoring role"
  default     = false
}

variable "monitoring_role_name" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  default = "rds-monitoring-role"
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  default = ""
}

# variable "iam_database_authentication_enabled" {
#   default = true
# }

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  default     = true
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html
variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Can result in a brief downtime as the server reboots"
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "sat:03:00-sat:05:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  default     = false
}

# variable "copy_tags_to_snapshot" {
#   description = "On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)"
#   default = false
# }

variable "backup_window" {
  description = "The window to perform backups. This should not overlap with the maintenance window"
  default     = "02:00-03:00"
}

variable "backup_retention_period" {
  description = "The days to retain backups for, 0 to disable"
  default     = 7
}

# https://www.terraform.io/docs/providers/aws/r/db_instance.html#enabled_cloudwatch_logs_exports
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported"
  default     = []
}

# iam_database_authentication_enabled

# monitoring_role_name = "MyRDSMonitoringRole"
# create_monitoring_role = true

# monitoring_interval - (Optional) The interval, in seconds, between points
# when Enhanced Monitoring metrics are collected for the DB instance. To
# disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.
# Valid Values: 0, 1, 5, 10, 15, 30, 60.
# https://www.terraform.io/docs/providers/aws/r/db_instance.html#monitoring_role_arn

# DB parameter group
variable "family" {
  description = "The family of the DB parameter group"
}

variable "parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "create_db_option_group" {
  description = "Whether or not to create db_option_group"
  default     = false
}

# RDS Performance Insights
variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  default     = null
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
  default     = null
}

variable "create_dns" {
  description = "Create DNS records for instance"
  default     = true
}

variable "dns_prefix" {
  description = "Prefix for DNS name"
  default = "db"
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type = list
}

variable "security_group_ids" {
  description = "Security group IDs"
  type = list
}

variable "kms_key_id" {
  description = "KMS key ARN"
  default = null
}

variable "dns_domain" {
  description = "Private DNS domain in the VPC"
  default = ""
}

variable "dns_zone_id" {
  description = "Private DNS zone_id in the VPC"
  default = ""
}
