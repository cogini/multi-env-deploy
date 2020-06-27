# Create IAM instance profile for prometheus

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-instance-profile-app"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "prometheus"

  enable_ec2_readonly = true
  enable_ecs_readonly = true

  # Allow writing to any log group and stream
  cloudwatch_logs = ["*"]
  # cloudwatch_logs = ["log-group:*"]
  # cloudwatch_logs = ["log-group:*:log-stream:*"]

  # Enable management via SSM
  enable_ssm_management = true
}
