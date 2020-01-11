# Give CodePipeline service roles access to S3 buckets for app component

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-codepipeline-app"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-worker"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"
  # Give acess to all SSM Parameter Store params under /org/app/env/comp
  # ssm_ps_params = ["*"]
  # Specify prefix and params
  ssm_ps_param_prefix = "cogini/foo/test"
  # ssm_ps_params = ["app/*", "worker/*"]
  ssm_ps_params = ["worker/*"]

  codepipeline_service_role_id = dependency.iam.outputs.codepipeline_service_role_id
  codedeploy_service_role_id = dependency.iam.outputs.codedeploy_service_role_id
  codebuild_service_role_id = dependency.iam.outputs.codebuild_service_role_id

  artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
  cache_bucket_arn = dependency.s3-codepipeline.outputs.buckets["build_cache"].arn
}
