# Create IAM service linked role for ECS

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html
#
# Equivalent to
# aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
#
# This role is normally created by e.g. the AWS console, so you may not need to
# create it. It also only exists once per account, so putting it in multiple
# Terraform projects can cause conflicts.
#
# Import an existing role like this:
#
# terragrunt import aws_iam_service_linked_role.this arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS
#
# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//iam-ecs"
# }
# include {
#   path = find_in_parent_folders()
# }

resource "aws_iam_service_linked_role" "this" {
  # count = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"
}
