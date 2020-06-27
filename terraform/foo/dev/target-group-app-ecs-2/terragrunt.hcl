 terraform {
   source = "${get_terragrunt_dir()}/../../../modules//target-group"
 }
 dependency "vpc" {
   config_path = "../vpc"
 }
 dependency "lb" {
   config_path = "../lb-public"
 }
 dependency "zone" {
   config_path = "../route53-public"
   # config_path = "../route53-cdn" # separate CDN domain
 }
 include {
   path = find_in_parent_folders()
 }

 inputs = {
   comp = "app"
   name = "app-ecs-2"

   hosts = ["app-ecs.${dependency.zone.outputs.name}"]

   port = 80
   protocol = "HTTP"

   health_check = {
     path = "/"
     interval = 30
     timeout = 10
     healthy_threshold = 2
     unhealthy_threshold = 2
     matcher = "200"
   }

   # stickiness = {
   #   type = "lb_cookie"
   # }

   listener_arn = dependency.lb.outputs.listener_arn
   vpc_id = dependency.vpc.outputs.vpc_id
   target_type = "ip"
 }
