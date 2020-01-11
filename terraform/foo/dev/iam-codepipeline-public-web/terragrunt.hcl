# Give CodePipeline service roles access to S3 buckets for app component

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-codepipeline-app"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-public-web"
}
dependencies {
  paths = [
  "../s3-public-web",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "public-web"

  # Give access to S3 buckets
  s3_buckets = {
    s3-public-web = {
      # Allow CodeBuild to run "aws s3 sync" to copy files
      web = {}
    }
  }

  cloudfront_create_invalidation = true

  codepipeline_service_role_id = dependency.iam.outputs.codepipeline_service_role_id
  codedeploy_service_role_id = dependency.iam.outputs.codedeploy_service_role_id
  codebuild_service_role_id = dependency.iam.outputs.codebuild_service_role_id

  artifacts_bucket_arn = dependency.s3-codepipeline.outputs.buckets["deploy"].arn
  cache_bucket_arn = dependency.s3-codepipeline.outputs.buckets["build_cache"].arn
}
