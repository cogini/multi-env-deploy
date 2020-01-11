# Create NAT instance for VPC

# A NAT instance is an EC2 instance which allows traffic outbound from
# instances in the private network segment. It does the same thing as a NAT
# Gateway, but is much cheaper to run. It has performance limits and
# generally is more trouble to run, but is useful for dev or smaller apps.

# https://registry.terraform.io/modules/int128/nat-instance/aws/0.5.0
module "nat" {
  source = "int128/nat-instance/aws"

  name                        = var.name
  vpc_id                      = var.vpc_id
  public_subnet               = var.public_subnet
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  private_route_table_ids     = var.private_route_table_ids
}
