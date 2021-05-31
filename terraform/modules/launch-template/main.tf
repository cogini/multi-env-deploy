# Create Launch Template for comp

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://www.terraform.io/docs/providers/aws/r/launch_template.html
resource "aws_launch_template" "this" {
  name_prefix = "${local.name}-"

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      # no_device    = lookup(block_device_mappings.value, "no_device", null)
      # virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten(tolist(lookup(block_device_mappings.value, "ebs", [])))
        content {
          # delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          # encrypted             = lookup(ebs.value, "encrypted", null)
          # iops                  = lookup(ebs.value, "iops", null)
          # kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          # snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          # volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", [])
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification
    content {
      cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
    }
  }
  # credit_specification {
  #   cpu_credits = "unlimited"
  # }

  # disable_api_termination = true

  ebs_optimized = var.ebs_optimized

  # elastic_gpu_specifications = var.elastic_gpu_specifications
  # elastic_inference_accellerator = var.elastic_inferernce_accellerator

  iam_instance_profile {
    name = var.instance_profile_name
  }

  image_id                             = var.image_id

  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = lookup(instance_market_options.value, "spot_options", [])
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  instance_type = var.instance_type

  # kernel_id = var.kernel_id
  key_name = var.keypair_name

  # license_specification = var.license_specification

  monitoring {
    enabled = var.enable_monitoring
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  # }

  # placement {
  #   availability_zone = "us-west-2a"
  # }

  # ram_disk_id

  vpc_security_group_ids = var.security_group_ids

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = local.name
      org   = var.org
      app   = var.app_name
      env   = var.env
      comp  = var.comp
      owner = var.owner
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name  = local.name
      org   = var.org
      app   = var.app_name
      env   = var.env
      comp  = var.comp
      owner = var.owner
    }
  }

  # Tags for launch configuration itself
  tags = {
    Name  = local.name
    org   = var.org
    app   = var.app_name
    env   = var.env
    comp  = var.comp
    owner = var.owner
  }

  user_data = var.user_data
  # user_data = "${base64encode(var.user_data)}"

  lifecycle {
    create_before_destroy = true
  }
}
