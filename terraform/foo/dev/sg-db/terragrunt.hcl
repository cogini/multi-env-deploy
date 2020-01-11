# Security group for RDS db

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    # "../sg-bastion",
    # "../sg-devops",
    "../sg-app-private",
    "../sg-app-public",
    "../sg-build-app",
    # "../sg-worker",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "rds-app"
  name = "foo-db"
  app_ports = [5432]
  app_sources = [
    # "sg-bastion",
    # "sg-devops",
    "sg-app-private",
    "sg-app-public",
    "sg-build-app",
    # "sg-worker",
  ]

  vpc_id = dependency.vpc.outputs.vpc_id
}
