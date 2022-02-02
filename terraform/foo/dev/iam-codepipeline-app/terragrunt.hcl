# Configure IAM permissions for CodePipeline components

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-codepipeline-app"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-app"
}
dependency "codestar-connection" {
  config_path = "../codestar-connection"
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
      # Allow CodeBuild to run "aws s3 sync" to copy files
      assets = {}
    }
  }

  # Give acess to all SSM Parameter Store params under /org/app/env/comp
  # ssm_ps_params = ["*"]
  # Give access to specific params under prefix
  ssm_ps_param_prefix = "cogini/foo/dev"
  # ssm_ps_params = ["app/*", "worker/*"]
  ssm_ps_params = ["app/*", "creds/*"]

  codepipeline_service_role_id = dependency.iam.outputs.codepipeline_service_role_id
  codedeploy_service_role_id = dependency.iam.outputs.codedeploy_service_role_id
  codebuild_service_role_id = dependency.iam.outputs.codebuild_service_role_id
  codestar_connection_arn = dependency.codestar-connection.outputs.arn

  artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
  cache_bucket_arn = dependency.s3-codepipeline.outputs.buckets["build_cache"].arn
}
