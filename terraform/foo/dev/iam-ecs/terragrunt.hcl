# Create IAM service linked role for ECS

# Equvalent to running
# aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//iam-ecs"
}
include "root" {
  path = find_in_parent_folders()
}
