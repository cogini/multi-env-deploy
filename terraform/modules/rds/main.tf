# Create RDS database instance for app

locals {
  name      = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  dns_name  = var.dns_name == "" ? "${var.comp}-db" : var.dns_name
  enable_sd = var.service_discovery_namespace_id == null ? false : true
}

# https://www.terraform.io/docs/providers/aws/d/db_instance.html

# https://www.terraform.io/docs/providers/aws/d/ssm_parameter.html
# data "aws_ssm_parameter" "db_master_password" {
#   name = "/${var.app_name}/${var.env}/${var.comp}/database/password/master"
# }

# data "aws_secretsmanager_secret" "db_master_password" {
#   name = "${var.app_name}-${var.env}-${var.comp}-database-master-password"
# }

# https://www.terraform.io/docs/providers/aws/d/secretsmanager_secret.html

# https://www.terraform.io/docs/providers/aws/r/db_instance.html
# https://github.com/terraform-aws-modules/terraform-aws-rds
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1.1"

  identifier         = local.name
  engine             = var.engine
  engine_version     = var.engine_version
  port               = var.port
  instance_class     = var.instance_class
  ca_cert_identifier = var.ca_cert_identifier

  replicate_source_db = var.replicate_source_db

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  iops              = var.iops

  multi_az = var.multi_az

  # DB parameter group
  family     = var.family
  parameters = var.parameters

  publicly_accessible = var.publicly_accessible

  create_db_option_group = var.create_db_option_group

  # name = var.app_name
  username = var.rds_master_user
  password = var.rds_master_pass
  db_name  = var.db_name

  # password = data.aws_ssm_parameter.db_master_password
  # password = data.aws_secretsmanager_secret.db_master_password

  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = var.monitoring_role_name
  create_monitoring_role = var.create_monitoring_role

  # Snapshot name upon DB deletion
  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier_prefix = "${local.name}-final"
  deletion_protection              = var.deletion_protection
  copy_tags_to_snapshot            = true

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window

  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period

  create_db_subnet_group = var.create_db_subnet_group
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  kms_key_id = var.storage_encrypted ? var.kms_key_id : null

  performance_insights_enabled = var.performance_insights_enabled
  # performance_insights_kms_key_id = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

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

# https://www.garretwilson.com/blog/2023/06/01/aws-ecs-service-connect-service-discovery-together
resource "aws_service_discovery_service" "this" {
  count = local.enable_sd ? 1 : 0

  name = local.dns_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 60
      type = "CNAME"
    }

    routing_policy = "WEIGHTED"
  }
}

resource "aws_service_discovery_instance" "this" {
  count = local.enable_sd ? 1 : 0

  instance_id = local.dns_name

  service_id = aws_service_discovery_service.this[0].id

  attributes = {
    AWS_INSTANCE_CNAME = module.db.db_instance_address
  }
}
