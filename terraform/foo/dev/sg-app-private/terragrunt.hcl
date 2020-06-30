# Security group for app running in private subnet

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//sg"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = [
    "../sg-lb-public",
    "../sg-bastion",
    "../sg-devops",
    "../sg-prometheus",
  ]
}

include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"
  # name = "foo-app-private" # Default app-comp
  app_ports = [80, 443, 4000, 4001]
  app_sources = ["sg-lb-public", "sg-bastion", "sg-devops", "sg-prometheus"]

  prometheus_ports = [9100, 9111]
  prometheus_sources = ["sg-prometheus"]

  ssh_sources = ["sg-bastion", "sg-devops"]
  icmp_sources = ["sg-bastion", "sg-devops"]
  extra_tags = { location = "internal" }

  vpc_id = dependency.vpc.outputs.vpc_id
}
