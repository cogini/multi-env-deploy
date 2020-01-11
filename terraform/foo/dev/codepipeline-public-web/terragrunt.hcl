# Create CodePipeline to build and deploy app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codepipeline"
}
dependency "kms" {
  config_path = "../kms"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3" {
  config_path = "../s3-public-web"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-public-web"
}
dependency "cloudfront" {
  config_path = "../cloudfront-public-web"
}
dependency "route53" {
  config_path = "../route53-public"
}
dependencies {
  paths = [
    "../iam-codepipeline-public-web",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "public-web"

  environment_variables = {
    BUCKET_WEB = dependency.s3.outputs.buckets["web"].id
    CLOUDFRONT_DISTRIBUTION_ID = dependency.cloudfront.outputs.id
    DNS_DOMAIN = dependency.route53.outputs.name
    HOST_NAME = "www"
    # SYNC_DELETE = true
  }

  # Source
  source_provider = "GitHub"
  # If private repo, set TF_VAR_github_oauth_token env var
  repo_owner = "cogini"
  repo_name = "codebuild-pelican-example"
  # repo_branch = "master"
  repo_poll = true

  # Build image, either AWS standard or custom from ECR
  build_image = "ubuntu:bionic"
  # build_image = "centos:7"
  # build_image = "${dependency.ecr.outputs.repository_url}:latest"

  kms_key_arn = dependency.kms.outputs.key_arn
  codepipeline_service_role_arn = dependency.iam.outputs.codepipeline_service_role_arn
  codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn

  artifacts_bucket_id = dependency.s3-codepipeline.outputs.buckets["deploy"].id
  cache_bucket_id = dependency.s3-codepipeline.outputs.buckets["build_cache"].id
}
