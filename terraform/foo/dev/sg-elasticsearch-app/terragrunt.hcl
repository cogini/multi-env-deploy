# Security group for Elasticsearch

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//sg"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = [
    "../sg-bastion",
    "../sg-devops",
    "../sg-app-private",
    "../sg-app-public",
    "../sg-worker",
  ]
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "elasticsearch-app"

  app_ports = [9200]
  app_sources = [
    "sg-bastion",
    "sg-devops",
    "sg-app-private",
    "sg-app-public",
    "sg-worker",
  ]

  vpc_id = dependency.vpc.outputs.vpc_id
}
