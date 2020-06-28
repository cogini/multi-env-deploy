# Create ECS IAM Task Execution role

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-ecs-task-execution"
}
dependency "kms" {
  config_path = "../kms"
}
dependencies {
  paths = []
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  # Allow creating CloudWatch Logs group
  cloudwatch_logs_create_group = true

  # Allow writing to any log group and stream
  cloudwatch_logs = ["*"]
  # cloudwatch_logs = ["log-group:*"]
  # cloudwatch_logs = ["log-group:*:log-stream:*"]

  # Give acess to all SSM Parameter Store params under /org/app/env/comp
  ssm_ps_params = ["*"]
  # Specify prefix and params
  # Give acess to all SSM Parameter Store params under /org/app/env
  ssm_ps_param_prefix = "cogini/foo/dev"
  # Give acess to specific params under prefix
  # ssm_ps_params = ["app/*", "worker/*"]

  # Give access to KMS CMK
  kms_key_arn = dependency.kms.outputs.key_arn
}
