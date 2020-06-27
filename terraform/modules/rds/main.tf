# Create RDS database instance for app component

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
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
  version = "~> 2.14.0"

  identifier     = local.name
  engine         = var.engine
  engine_version = var.engine_version
  port           = var.port
  instance_class = var.instance_class
  ca_cert_identifier = var.ca_cert_identifier

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

  # password = data.aws_ssm_parameter.db_master_password
  # password = data.aws_secretsmanager_secret.db_master_password

  monitoring_interval = var.monitoring_interval
  monitoring_role_name = var.monitoring_role_name
  create_monitoring_role = var.create_monitoring_role

  # Snapshot name upon DB deletion
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${local.name}-final"
  deletion_protection       = var.deletion_protection
  copy_tags_to_snapshot     = true

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window

  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period

  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids

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

resource "aws_route53_record" "db" {
  count   = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = "${var.dns_prefix}.${var.comp}.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [module.db.this_db_instance_address]
}
