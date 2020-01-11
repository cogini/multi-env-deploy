# Create NAT instance

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//nat"
}
dependency "vpc" {
  config_path = "../vpc"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  name                        = "foo"
  vpc_id                      = dependency.vpc.outputs.vpc_id
  public_subnet               = dependency.vpc.outputs.public_subnets[0]
  private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
  private_route_table_ids     = dependency.vpc.outputs.private_route_table_ids
}
