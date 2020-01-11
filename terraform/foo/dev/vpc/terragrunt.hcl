# Create VPC

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//vpc"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  cidr                = "10.10.0.0/16"
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24"]
  database_subnets    = ["10.10.21.0/24", "10.10.22.0/24"]
  elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24"]

  # enable_nat_gateway = true
  # single_nat_gateway = true
}
