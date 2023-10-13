# Create EC2 instances in public VPC network

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//ec2-public"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "iam" {
#   config_path = "../iam-instance-profile-app"
# }
# dependency "sg" {
#   config_path = "../sg-app-public"
# }
# dependency "route53" {
#   config_path = "../route53-public"
# }
# include "root" {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#   name = "foo-app-ec2"
#
#   extra_tags = {
#     deploy_hook = "foo-app-ec2"
#   }
#
#   # Create one per az
#   # instance_count = 0
#
#   instance_type = "t3.nano"
#
#   # Ubuntu 18.04
#   # ami = "ami-0f63c02167ca94956"
#
#   subnet_ids = dependency.vpc.outputs.subnets["public"]
#   security_group_ids = [dependency.sg.outputs.security_group_id]
#   instance_profile_name = dependency.iam.outputs.instance_profile_name
#
#   create_dns = true
#   dns_domain = dependency.route53.outputs.name
#   dns_zone_id = dependency.route53.outputs.zone_id
# }

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
}

locals {
  name      = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  host_name = var.host_name == "" ? var.comp : var.host_name
  fqdn      = "${local.host_name}.${var.dns_domain}"
  ami       = var.ami == "" ? data.aws_ami.this.id : var.ami
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
  availability_zone                    = var.availability_zones[count.index]
  associate_public_ip_address          = true
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

resource "aws_eip" "this" {
  count    = var.assign_eip ? 1 : 0
  instance = aws_instance.this[0].id
  vpc      = true
}

resource "aws_route53_health_check" "this" {
  count = (var.create_dns && var.dns_health_check) ? 1 : 0

  fqdn              = local.fqdn
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_resource_path
  failure_threshold = var.health_check_failure_threshold
  request_interval  = var.health_check_request_interval

  tags = {
    Name = "${var.app_name}-${local.host_name}-health-check"
  }
}

resource "aws_route53_record" "this" {
  count = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = local.fqdn
  ttl     = var.dns_ttl
  type    = "A"
  records = var.assign_eip ? aws_eip.this.*.public_ip : aws_instance.this.*.public_ip
}

# https://github.com/terraform-providers/terraform-provider-aws/issues/1707
# resource "aws_route53_record" "this-aaaa" {
#   count   = var.create_dns ? 1 : 0
#
#   zone_id = var.zone_id
#   name = local.fqdn
#   type    = "AAAA"
#   ttl     = var.dns_ttl
#   records = aws_instance.this.*.ipv6_addresses
# }
