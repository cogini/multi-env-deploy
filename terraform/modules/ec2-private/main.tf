# Create EC2 instances in private VPC network

# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//ec2-private"
# }
# dependency "iam" {
#   config_path = "../iam-instance-profile-devops"
# }
# dependency "sg" {
#   config_path = "../sg-devops"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# include "root" {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "devops"
#
#   # Create a single instance
#   instance_count = 1
#
#   # Create one per az
#   # instance_count = 0
#
#   instance_type = "t4g.nano"
#
#   # Ubuntu 18.04
#   # ami = "ami-0f63c02167ca94956"
#
#   keypair_name = "foo-dev"
#
#   # root_volume_size = 400
#
#   subnet_ids = dependency.vpc.outputs.subnets["private"]
#   security_group_ids = [dependency.sg.outputs.security_group_id]
#   instance_profile_name = dependency.iam.outputs.instance_profile_name
#
#   create_dns = true
#   dns_domain = dependency.vpc.outputs.private_dns_domain
#   dns_zone_id = dependency.vpc.outputs.private_dns_zone_id
# }

data "aws_availability_zones" "available" {}

# data "aws_ec2_instance_type" "this" {
#   count         = var.enabled ? 1 : 0
#   instance_type = var.instance_type
# }

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
# https://discourse.ubuntu.com/t/search-and-launch-ubuntu-22-04-in-aws-using-cli/27986
data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = var.ami_filter
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # filter {
  #   name   = "architecture"
  #   values = data.aws_ec2_instance_type.this[count.index].supported_architectures
  # }

  # filter {
  #   name   = "virtualization-type"
  #   values = ["hvm"]
  # }
}

locals {
  name      = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  host_name = var.host_name == "" ? var.comp : var.host_name
  fqdn      = "${local.host_name}.${var.dns_domain}"
  ami       = var.ami == "" ? data.aws_ami.this.id : var.ami
  availability_zones = var.availability_zones == [] ? data.aws_availability_zones.available.names : var.availability_zones
}

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "this" {
  count = var.instance_count > 0 ? var.instance_count : length(var.subnet_ids)

  ami                                  = local.ami
  instance_type                        = var.instance_type
  user_data                            = var.user_data
  key_name                             = var.keypair_name
  monitoring                           = var.monitoring
  subnet_id                            = element(distinct(compact(var.subnet_ids)), count.index)
  vpc_security_group_ids               = var.security_group_ids
  iam_instance_profile                 = var.instance_profile_name
  availability_zone                    = local.availability_zones[count.index]
  associate_public_ip_address          = false
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  ebs_optimized                        = var.ebs_optimized
  root_block_device {
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_volume_delete_on_termination
  }

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
      "index" = count.index
    },
    var.extra_tags,
  )

  volume_tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
      "index" = count.index
    },
    var.extra_tags,
  )
}

resource "aws_route53_record" "this" {
  count = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = local.fqdn
  ttl     = var.dns_ttl
  type    = "A"
  records = aws_instance.this[*].private_ip
  # name    = local.host_name
  # type    = "CNAME"
  # records = aws_instance.this[*].private_dns
}
