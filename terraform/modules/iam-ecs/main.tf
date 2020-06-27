# Create IAM service linked role for ECS

# Equivalent to
# aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com

# This role is normally created by e.g. the AWS console, so you may
# not need to create it. It also only exists once per account, so putting
# it in multiple Terraform projects can cause conflicts.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-ecs"
# }
# include {
#   path = find_in_parent_folders()
# }

resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "ecs.amazonaws.com"
}
