# Create security groups

# Example config:
#
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//sg"
# }
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependencies {
#   paths = [
#     # "../sg-bastion",
#     # "../sg-devops",
#     "../sg-app-private",
#     "../sg-app-public",
#     "../sg-build-app",
#     # "../sg-worker",
#   ]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "rds-app"
#   name = "foo-db"
#   app_ports = [5432]
#   app_sources = [
#     # "sg-bastion",
#     # "sg-devops",
#     "sg-app-private",
#     "sg-app-public",
#     "sg-build-app",
#     # "sg-worker",
#   ]
#
#   vpc_id = dependency.vpc.outputs.vpc_id
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

locals {
  security_groups = distinct(concat(var.app_sources,
    var.prometheus_sources,
    var.ssh_sources,
    var.icmp_sources
  ))
}

data "terraform_remote_state" "sg" {
  for_each = toset(local.security_groups)
  backend = "s3"
  config = {
    bucket = var.remote_state_s3_bucket_name
    key    = "${var.remote_state_s3_key_prefix}/${each.key}/terraform.tfstate"
    region = var.remote_state_s3_bucket_region
  }
}

locals {
  sg_ids = {for i in local.security_groups : i => data.terraform_remote_state.sg[i].outputs.security_group_id}
}

resource "aws_security_group" "this" {
  name   = local.name
  vpc_id = var.vpc_id

  # Allow traffic from anyone on these ports, protocols
  dynamic "ingress" {
    #iterator = port
    for_each = {
      for i in setproduct(var.ingress_ports, var.ingress_protocols) : "${i[0]}/${i[1]}" => {
        port = i[0]
        protocol = i[1]
      }
    }
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Allow traffic from custom ip address on these ports, protocols
  dynamic "ingress" {
    #iterator = port
    for_each = {
      for i in setproduct(var.custom_ports, var.custom_protocols, var.custom_cidr_blocks) : "${i[0]}/${i[1]}/${i[2]}" => {
        port = i[0]
        protocol = i[1]
        cidr_block = i[2]
      }
    }
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_block]
    }
  }

  # Allow traffic to app ports, e.g. HTTP, from specific source groups
  dynamic "ingress" {
    iterator = port
    for_each = length(var.app_sources) > 0 ? var.app_ports : []
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      security_groups = [for i in var.app_sources : local.sg_ids[i]]
    }
  }

  # Allow traffic to prometheus exporter ports from specific source groups
  dynamic "ingress" {
    iterator = port
    for_each = length(var.prometheus_sources) > 0 ? var.prometheus_ports : []
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      security_groups = [for i in var.prometheus_sources : local.sg_ids[i]]
    }
  }

  # Allow traffic to ssh from specific source groups
  dynamic "ingress" {
    iterator = port
    for_each = length(var.ssh_sources) > 0 ? var.ssh_ports : []
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      security_groups = [for i in var.ssh_sources : local.sg_ids[i]]
    }
  }

  # Allow traffic from machines in same security group
  dynamic "ingress" {
    for_each = var.allow_self ? list(1) : []
    content {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      self      = true
    }
  }

  # Allow icmp (ping) traffic from specific source groups
  dynamic "ingress" {
    for_each = length(var.icmp_sources) > 0 ? list(1) : []
    content {
      from_port = 0
      to_port   = 0
      protocol  = "icmp"
      security_groups = [for i in var.icmp_sources : local.sg_ids[i]]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name"     = local.name
      "org"      = var.org
      "app"      = var.app_name
      "comp"     = var.comp
      "env"      = var.env
      "owner"    = var.owner
    },
    var.extra_tags,
  )
}
