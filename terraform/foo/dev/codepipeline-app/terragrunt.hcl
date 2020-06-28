# Create CodePipeline to build and deploy app

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codepipeline"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependency "sg" {
  config_path = "../sg-build-app"
}
dependency "kms" {
  config_path = "../kms"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3" {
  config_path = "../s3-app"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-app"
}
dependency "ecr-build" {
  config_path = "../ecr-build-app"
}
# dependency "ecr" {
#   config_path = "../ecr-app"
# }
# dependency "cloudfront" {
#   config_path = "../cloudfront-app-assets"
# }
# dependency "codecommit-repo" {
#   config_path = "../codecommit-repo-app"
# }
dependency "codedeploy-app" {
  config_path = "../codedeploy-app"
}
dependency "codedeploy-deployment-asg" {
  config_path = "../codedeploy-deployment-app-asg"
}
dependency "codedeploy-deployment-ec2" {
  config_path = "../codedeploy-deployment-app-ec2"
}
# dependency "zone" {
#   config_path = "../route53-public"
#   # config_path = "../route53-cdn" # separate CDN domain
# }
dependencies {
  paths = [
    "../iam-codepipeline-app",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  environment_variables = {
    BUCKET_ASSETS = dependency.s3.outputs.buckets["assets"].id
    BUCKET_CONFIG = dependency.s3.outputs.buckets["config"].id
    # If the build process needs to invalidate the CDN cache
    # CLOUDFRONT_DISTRIBUTION_ID = dependency.cloudfront.outputs.id
    # If the build process needs to know where the assets will be deployed
    # DNS_DOMAIN = dependency.route53.outputs.name
  }

  # Source
  source_provider = "GitHub"
  # If private repo, set TF_VAR_github_oauth_token env var
  repo_owner = "cogini"
  repo_name = "mix-deploy-example"
  # repo_branch = "master"
  repo_poll = true

  # source_provider = "CodeCommit"
  # repo_branch = "master"
  # repo_branch = dependency.codecommit-repo.outputs.default_branch
  # codecommit_repository_name = dependency.codecommit-repo.outputs.repository_name

  # Build
  # Build image, either AWS standard or custom from ECR
  # codebuild_image = "ubuntu:bionic"
  # codebuild_image = "centos:7"
  # codebuild_image = "aws/codebuild/standard:2.0"
  # codebuild_image = "aws/codebuild/docker:18.09.0"
  # codebuild_image = "aws/codebuild/docker:19.03.11"
  codebuild_image = "${dependency.ecr-build.outputs.repository_url}:latest"
  # codebuild_compute_type = "BUILD_GENERAL1_MEDIUM"

  # Deploy
  codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
  codedeploy_deployment_groups = [
    dependency.codedeploy-deployment-asg.outputs.deployment_group_name,
    dependency.codedeploy-deployment-ec2.outputs.deployment_group_name,
  ]

  kms_key_arn = dependency.kms.outputs.key_arn
  codepipeline_service_role_arn = dependency.iam.outputs.codepipeline_service_role_arn
  codebuild_service_role_arn = dependency.iam.outputs.codebuild_service_role_arn

  artifacts_bucket_id = dependency.s3-codepipeline.outputs.buckets["deploy"].id
  cache_bucket_id = dependency.s3-codepipeline.outputs.buckets["build_cache"].id

  subnet_ids = dependency.vpc.outputs.subnets["private"]
  security_group_ids = [dependency.sg.outputs.security_group_id]
  vpc_id = dependency.vpc.outputs.vpc_id
}
