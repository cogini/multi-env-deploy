# Create an ASG for an app component which handles background jobs

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//asg-worker"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "lt" {
  config_path = "../launch-template-app"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"

  image_id = "ami-03c363c16a1c450a9"

  # Ubuntu 18.04
  # image_id = "ami-0f63c02167ca94956"

  # CentOS 7
  # image_id = "ami-8e8847f1"

  # Amazon Linux 2
  # image_id = "ami-0d7ed3ddb85b521a6"

  # root_block_device = [{ volume_size = "60" }]

  min_size = 1
  max_size = 3
  desired_capacity = 1
  wait_for_capacity_timeout = "2m"

  health_check_grace_period = 30
  # health_check_type = "ELB"
  health_check_type = "EC2"

  subnets = dependency.vpc.outputs.subnets["private"]

  launch_template_id = dependency.lt.outputs.launch_template_id
  launch_template_version = "$Latest" # $Latest, or $Default
  # spot_max_price = ""

  force_delete = true
}
