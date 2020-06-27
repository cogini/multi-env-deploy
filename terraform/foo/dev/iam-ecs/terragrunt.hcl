# Create IAM service linked role for ECS

# Equvalent to running
# aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-ecs"
}
include {
  path = find_in_parent_folders()
}
