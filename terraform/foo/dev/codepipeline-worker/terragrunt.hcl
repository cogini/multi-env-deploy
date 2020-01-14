# Create CodePipeline to build and deploy worker

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codepipeline"
}
# dependency "vpc" {
#   config_path = "../vpc"
# }
# dependency "sg" {
#   config_path = "../sg-build-worker"
# }
dependency "kms" {
  config_path = "../kms"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "s3" {
  config_path = "../s3-worker"
}
dependency "s3-codepipeline" {
  config_path = "../s3-codepipeline-worker"
}
dependency "ecr" {
  config_path = "../ecr-build-worker"
}
# dependency "cloudfront" {
#   # config_path = "../cloudfront-public-web"
#   config_path = "../cloudfront-app-assets"
# }
# dependency "codecommit-repo" {
#   config_path = "../codecommit-repo-app"
# }
dependency "codedeploy-app" {
  config_path = "../codedeploy-worker"
}
dependency "codedeploy-deployment-asg" {
  config_path = "../codedeploy-deployment-worker-asg"
}
dependency "codedeploy-deployment-ec2" {
  config_path = "../codedeploy-deployment-worker-ec2"
}
dependencies {
  paths = [
    "../iam-codepipeline-worker",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "worker"

  environment_variables = {
    # BUCKET_ASSETS = dependency.s3.outputs.buckets["assets"].id
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

  # Build image, either AWS standard or custom from ECR
  # build_image = "ubuntu:bionic"
  # build_image = "centos:7"
  build_image = "${dependency.ecr.outputs.repository_url}:latest"

  buildspec = "buildspec-worker.yml"

  # Deployment
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

  # subnet_ids = dependency.vpc.outputs.subnets["public"]
  # security_group_ids = [dependency.sg.outputs.security_group_id]
  # vpc_id = dependency.vpc.outputs.vpc_id
}
