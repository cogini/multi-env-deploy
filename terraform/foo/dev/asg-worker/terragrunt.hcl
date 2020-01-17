# Create an ASG for an app component which handles background jobs

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//asg"
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

  min_size = 0
  max_size = 3
  desired_capacity = 1

  wait_for_capacity_timeout = "2m"

  health_check_grace_period = 30
  # health_check_type = "ELB"
  health_check_type = "EC2"

  subnets = dependency.vpc.outputs.subnets["private"]

  launch_template_id = dependency.lt.outputs.launch_template_id
  launch_template_version = "$Latest" # $Latest, or $Default
  spot_max_price = ""
  on_demand_base_capacity = 0
  on_demand_percentage_above_base_capacity = 0
  override_instance_types = ["t3.nano", "t3a.nano"]

  force_delete = true
}
