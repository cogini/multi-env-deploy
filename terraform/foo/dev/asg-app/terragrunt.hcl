# Create an ASG for an app component which responds to client requests
# via the load balancer.

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//asg-app"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "lt" {
  config_path = "../launch-template-app"
}
dependency "tg" {
  config_path = "../target-group-default"
  # config_path = "../target-group-app"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  min_size = 1
  max_size = 3
  desired_capacity = 1
  wait_for_capacity_timeout = "2m"
  # Wait for this number of healthy instances in load balancer
  wait_for_elb_capacity = 1

  health_check_grace_period = 30
  # health_check_type = "ELB"
  health_check_type = "EC2"

  target_group_arns = [dependency.tg.outputs.arn]

  subnets = dependency.vpc.outputs.subnets["private"]

  launch_template_id = dependency.lt.outputs.launch_template_id
  launch_template_version = "$Latest" # $Latest, or $Default
  # spot_max_price = ""

  force_delete = true
}
