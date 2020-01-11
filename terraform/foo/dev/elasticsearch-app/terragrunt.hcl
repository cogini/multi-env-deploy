# Create Elasticsearch domain

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//elasticsearch"
}
# dependency "kms" {
#   config_path = "../kms"
# }
dependency "vpc" {
  config_path = "../vpc"
}
dependency "sg" {
  config_path = "../sg-elasticsearch-app"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  instance_type = "t2.small.elasticsearch"
  instance_count = 1
  elasticsearch_version = "6.3"

  # Encryption at rest is not supported with t2.small.elasticsearch instances
  # encrypt = true
  # kms_key_id = dependency.kms.outputs.key_id

  subnet_ids = dependency.vpc.outputs.subnets["database"]
  private_dns_somain = dependency.vpc.outputs.private_dns_domain
  security_group_ids = [dependency.sg.outputs.security_group_id]
}
