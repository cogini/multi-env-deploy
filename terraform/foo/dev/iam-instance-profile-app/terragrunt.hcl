# Create IAM instance profile for app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-instance-profile-app"
}
dependency "kms" {
  config_path = "../kms"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-app"
}
dependencies {
  paths = [
    "../s3-app",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  # Give access to S3 buckets
  s3_buckets = {
    s3-app = {
      # assets = {}
      # Allow read only access to config bucket
      config = {
        actions = ["s3:ListBucket", "s3:List*", "s3:Get*"]
      }
      data = {
        actions = ["s3:ListBucket", "s3:List*", "s3:Get*", "s3:PutObject*", "s3:DeleteObject"]
      }
      logs = {}
      # protected_web = {}
      # public_web = {}
      ssm = {
        actions = ["s3:PutObject", "s3:GetEncryptionConfiguration"]
      }
    }
  }

  # Allow writing to any log group and stream
  cloudwatch_logs = ["*"]
  # cloudwatch_logs = ["log-group:*"]
  # cloudwatch_logs = ["log-group:*:log-stream:*"]

  # Enable writing metrics to any namespace
  cloudwatch_metrics_namespace = "*"
  # Allow writing to specific namespace
  # cloudwatch_metrics_namespace = "Foo"

  # Enable writing to AWS X-Ray
  xray = true

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
