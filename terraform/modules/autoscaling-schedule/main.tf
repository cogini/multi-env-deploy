# Create an ASG for an app which responds to client requests
# via the load balancer.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//autoscaling-schedule"
# }
# dependency "asg" {
#   config_path = "../asg-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = { 
#   comp = "app"
#    
#   autoscaling_actions = { 
#     up = { 
#       name = "scale_up"
#       asg_name = dependency.asg.outputs.autoscaling_group_name
#       min_size = 5 
#       max_size = 15
#       desired_capacity = 10
#       recurrence = "0 15 * * *"
#     }   
#     down = { 
#       name = "scale_down"
#       asg_name = dependency.asg.outputs.autoscaling_group_name
#       min_size = 5 
#       max_size = 15
#       desired_capacity = 5 
#       recurrence = "0 0 * * *"
#     }   
#   }
#
# }

resource "aws_autoscaling_schedule" "this" {
  for_each = var.autoscaling_actions
    scheduled_action_name = each.value["name"]
    autoscaling_group_name = each.value["asg_name"]
    min_size = each.value["min_size"]
    max_size = each.value["max_size"]
    desired_capacity = each.value["desired_capacity"]
    recurrence = each.value["recurrence"]
}
