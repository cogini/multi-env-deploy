# Register EC2 instances with an ALB target group

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//tg-ec2-attachment"
# }
# dependency "tg" {
#   config_path = "../target-group-default"
# }
# dependency "ec2" {
#   config_path = "../ec2-app"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "app"
#   port = 4000
#
#   target_group_arn = dependency.ec2.outputs.arn
#   ips = dependency.ec2.outputs.public_ip
# }

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.ips)
  target_group_arn = var.target_group_arn
  target_id        = element(var.ips, count.index)
  port             = var.port
}
