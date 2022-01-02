# Create RDS database for app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//rds"
}
# dependency "kms" {
#   config_path = "../kms"
# }
dependency "vpc" {
  config_path = "../vpc"
}
dependency "sg" {
  config_path = "../sg-db"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  security_group = "db" # legacy

  # Settings appropriate for dev db
  allocated_storage = 5
  multi_az = false
  deletion_protection = false
  # disable backups to create DB faster
  backup_retention_period = 0
  skip_final_snapshot = true
  # apply_immediately = true

  # Micro doesn't support encryption, only small
  # storage_encrypted = true
  # instance_class = "db.t2.small"

  subnet_ids = dependency.vpc.outputs.subnets["database"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  dns_domain = dependency.vpc.outputs.private_dns_domain
  dns_zone_id = dependency.vpc.outputs.private_dns_zone_id

  # kms_key_id = dependency.kms.outputs.key_arn

  # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  engine = "postgres"
  # aws rds describe-db-engine-versions --engine postgres | jq '.DBEngineVersions[].EngineVersion'
  engine_version = "11.12"
  port = "5432"
  # aws rds describe-db-engine-versions --engine postgres | jq '.DBEngineVersions[].DBParameterGroupFamily'
  # family = "postgres9.6"
  family = "postgres11"
  # DB option group
  # major_engine_version = "9.6"
  # major_engine_version = "10"
  rds_master_user = "postgresql"
  # Set rds_master_pass via environment var

  ca_cert_identifier = "rds-ca-2019"

  # create_monitoring_role = true
  # monitoring_interval = 60
  # performance_insights_enabled = true
  # performance_insights_retention_period = 7

  # parameters = [
  #   {
  #     name = "rds.force_ssl",
  #     value = 1
  #   }
  #   {
  #     name = "shared_preload_libraries",
  #     value = "pg_stat_statements",
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "pg_stat_statements.track",
  #     value = "all",
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "track_activity_query_size",
  #     value = "2048",
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "idle_in_transaction_session_timeout",
  #     value = "3600000",
  #     apply_method = "dynamic"
  #   }
  # ]

  # https://github.com/terraform-aws-modules/terraform-aws-vpc#public-access-to-rds-instances
  # Allow public access to RDS instance
  # create_database_subnet_group           = true
  # create_database_subnet_route_table     = true
  # create_database_internet_gateway_route = true
  # publicly_accessible = "false"

  # engine = "mysql"
  # engine_version = "5.7.17"
  # port = "3306"
  # family = "mysql5.7"
  # major_engine_version = "5.7"
  # parameters = [
  #   {
  #     name = "log_bin_trust_function_creators"
  #     value = "1"
  #   },
  #   {
  #     name = "tx_isolation"
  #     value = "repeatable-read"
  #   },
  #   {
  #     name = "back_log"
  #     value = "50"
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "query_cache_size"
  #     value = "134217728"
  #   },
  #   {
  #     name = "slow_query_log"
  #     value = "1"
  #   },
  #   {
  #     name = "long_query_time"
  #     value = "2"
  #   },
  #   {
  #     name = "binlog_cache_size"
  #     value = "1048576"
  #   },
  #   //  {
  #   //    name = "innodb_file_per_table"
  #   //    value = "1"
  #   //  },
  #   {
  #     name = "innodb_file_format"
  #     value = "barracuda"
  #   },
  #   {
  #     name = "innodb_large_prefix"
  #     value = "1"
  #   },
  #   {
  #     name = "innodb_thread_concurrency"
  #     value = "6"
  #   },
  #   {
  #     name = "innodb_flush_log_at_trx_commit"
  #     value = "1"
  #   },
  #   {
  #     name = "innodb_log_buffer_size"
  #     value = "16777216"
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "innodb_open_files"
  #     value = "2000"
  #     apply_method = "pending-reboot"
  #   },
  #   {
  #     name = "max_allowed_packet"
  #     value = "67108864"
  #   },
  #   {
  #     name = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "character_set_connection"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "character_set_database"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "character_set_filesystem"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "character_set_results"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "character_set_server"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name = "innodb_stats_persistent"
  #     value = "0"
  #   },
  #   {
  #     name = "innodb_stats_persistent_sample_pages"
  #     value = "20"
  #   },
  #   {
  #     name = "innodb_stats_auto_recalc"
  #     value = "0"
  #   }
  # ]
}
