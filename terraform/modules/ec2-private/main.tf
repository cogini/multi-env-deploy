# Create EC2 instances in private VPC network

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//ec2-private"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "sg" {
#   config_path = "../sg-worker"
# }
# dependency "iam" {
#   config_path = "../iam-instance-profile-worker"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "worker"
#   name = "foo-worker-ec2"
#   security_group = "worker"
#
#   instance_type = "t3.nano"
#
#   extra_tags = {
#     deploy_hook = "foo-worker-ec2"
#   }
#
#   # Create a single instance
#   instance_count = 1
#
#   # Ubuntu 18.04
#   ami = "ami-0f63c02167ca94956"
#
#   # CentOS 7
#   # ami = "ami-8e8847f1"
#
#   # Amazon Linux 2
#   # ami = "ami-0d7ed3ddb85b521a6"
#
#   security_group_ids = [dependency.sg.outputs.security_group_id]
#   iam_instance_profile = dependency.iam.outputs.instance_profile_name
#   subnet_ids = dependency.vpc.outputs.subnets["private"]
#   dns_domain = dependency.vpc.outputs.private_dns_domain
#   dns_zone_id = dependency.vpc.outputs.private_dns_zone_id
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
  host_name = var.host_name == "" ? var.comp : var.host_name
  fqdn = "${local.host_name}.${var.dns_domain}"
}

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "this" {
  count = var.instance_count > 0 ? var.instance_count : length(var.subnet_ids)

  ami           = var.ami
  instance_type = var.instance_type
  user_data     = var.user_data
  key_name      = var.keypair_name
  monitoring    = var.monitoring
  subnet_id     = var.subnet_ids[count.index]
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.instance_profile_name
  availability_zone           = var.availability_zones[count.index]
  associate_public_ip_address = false
  disable_api_termination     = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  root_block_device {
    volume_size = var.root_volume_size
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
  count   = var.create_dns ? 1 : 0

  zone_id = var.dns_zone_id
  name    = local.fqdn
  ttl     = var.dns_ttl
  type    = "A"
  records = aws_instance.this[*].private_ip
  # name    = local.host_name
  # type    = "CNAME"
  # records = aws_instance.this[*].private_dns
}
