# Create S3 buckets for CodePipeline, i.e. artifacts and build cache

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//s3-app"
}
dependency "kms" {
  config_path = "../kms"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "public-web"

  # Force S3 buckets to be deleted even when they are not empty
  # This is useful in dev, but dangerous in prod
  force_destroy = true

  buckets = {
    # App assets such as CSS and JS published via CDN
    # assets = {
    #   website = true
    #   acl = "public-read"
    # }
    # Config files
    # config = {
    #   encrypt = true
    # }
    # Data files
    # data = {
    #   encrypt = true
    # }
    # Log files
    # logs = {
    #   encrypt= true
    # }
    # App public web files, e.g. user logos for whitelabel
    # public_web = {
    #   website = true
    #   acl = "public-read"
    # }
    # App web files with controlled access, e.g. user data
    # protected_web = {
    #   website = true
    #   encrypt = true
    # }
    # SSM files
    # ssm = {
    #   encrypt = true
    # }

    # CodeBuild cache
    build_cache = {
      encrypt = true
    }
    # CodePipeline deploy
    deploy = {
      encrypt = true
    }
  }

  kms_key_id = dependency.kms.outputs.key_arn
}
