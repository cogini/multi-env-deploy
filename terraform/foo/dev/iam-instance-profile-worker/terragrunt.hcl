# Create IAM instance profile for app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-instance-profile-app"
}
dependency "kms" {
  config_path = "../kms"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-worker"
}
dependencies {
  paths = [
    "../s3-worker",
    "../s3-app",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"

  # Give access to S3 buckets
  s3_buckets = {
    s3-worker = {
      # assets = {}
      # Allow read only access to config bucket
      config = {
        actions = ["s3:ListBucket", "s3:List*", "s3:Get*"]
      }
      ssm = {
        actions = ["s3:PutObject", "s3:GetEncryptionConfiguration"]
      }
    }
    # Give access to app bucket to share files
    s3-app = {
      data = {}
    }
  }

  # Allow writing to any log group and stream
  cloudwatch_logs = ["*"]
  # cloudwatch_logs = ["log-group:*"]
  # cloudwatch_logs = ["log-group:*:log-stream:*"]

  # Give access to CodeDeploy S3 buckets
  enable_codedeploy = true
  artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn

  # Give acess to all SSM Parameter Store params under /org/app/env/comp
  ssm_ps_params = ["*"]
  # Specify prefix and params
  # ssm_ps_param_prefix = "cogini/foo/dev"
  # ssm_ps_params = ["app/*", "worker/*"]

  # Enable management via SSM
  enable_ssm_management = true

  # Give access to KMS CMK
  kms_key_arn = dependency.kms.outputs.key_arn
}
