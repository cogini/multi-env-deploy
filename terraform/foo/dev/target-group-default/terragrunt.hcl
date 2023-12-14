terraform {
  source = "${dirname(find_in_parent_folders())}/modules//target-group-default"
}
dependency "vpc" {
  config_path = "../vpc"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  port = 4001
  protocol = "HTTPS"
  # protocol = "HTTP"

  health_check = {
    # If you don't specify the port, it uses the same as the traffic port
    # You still need to specify HTTPS, though
    port = 4001
    protocol = "HTTPS"
    path = "/healthz"
    interval = 30
    timeout = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }

  # stickiness = {
  #   type = "lb_cookie"
  # }

  vpc_id = dependency.vpc.outputs.vpc_id
}
