# Create NAT instance for VPC

# A NAT instance is an EC2 instance which allows traffic outbound from
# instances in the private network segment. It does the same thing as a NAT
# Gateway, but is much cheaper to run. It has performance limits and
# generally is more trouble to run, but is useful for dev or smaller apps.

# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//nat"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
#
# include "root" {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   vpc_id                      = dependency.vpc.outputs.vpc_id
#   public_subnet               = dependency.vpc.outputs.public_subnets[0]
#   private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
#   private_route_table_ids     = dependency.vpc.outputs.private_route_table_ids
# }

data "aws_ami" "fck_nat" {
  filter {
    name   = "name"
    values = ["fck-nat-amzn2-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners      = ["568608671756"]
  most_recent = true
}

locals {
  name = var.name == "" ? var.app_name : var.name
  image_id = var.image_id == null ? data.aws_ami.fck_nat.id : var.image_id

  tags = merge(
    {
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

# https://registry.terraform.io/modules/int128/nat-instance/aws/0.5.0
module "nat" {
  source = "int128/nat-instance/aws"

  name                        = local.name
  vpc_id                      = var.vpc_id
  public_subnet               = var.public_subnet
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  private_route_table_ids     = var.private_route_table_ids
  enabled                     = var.enabled

  image_id = local.image_id
  instance_types = var.instance_types
  key_name = var.key_name

  # enable port forwarding (optional)
  # user_data_write_files = [
  #   {
  #     path : "/opt/nat/dnat.sh",
  #     content : templatefile("./dnat.sh", { ec2_name = "nat-instance-${local.name}" }),
  #     permissions : "0755",
  #   },
  #   {
  #     path : "/etc/systemd/system/dnat.service",
  #     content : file("./dnat.service"),
  #   },
  # ]
  # user_data_runcmd = [
  #   ["yum", "install", "-y", "jq"],
  #   ["systemctl", "enable", "dnat"],
  #   ["systemctl", "start", "dnat"],
  # ]
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-${local.name}"
  }
}
