# Create S3 buckets for app

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//s3-app"
}
dependency "kms" {
  config_path = "../kms"
}
# dependency "route53" {
#   config_path = "../route53-public"
#   # config_path = "../route53-cdn" # separate CDN domain
# }
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  # Force S3 buckets to be deleted even when they are not empty
  # This is useful in dev, but dangerous in prod
  force_destroy = true

  buckets = {
    # App assets such as CSS and JS published via CDN
    assets = {
      encrypt = false
      cors = true
    }
    # Config files
    config = {
      encrypt = true
    }
    # Data files
    data = {
      encrypt = true
    }
    # SSM log files
    ssm = {
      encrypt = true
    }
    # Log files
    # logs = {
    #   encrypt = true
    # }
    # App public web files, e.g. logos for whitelabel, served from S3
    # public_web = {
    #   name = "public.${dependency.route53.outputs.name_nodot}"
    # }
    # App web files with controlled access, e.g. user data
    # protected_web = {
    #   name = "protected.${dependency.route53.outputs.name_nodot}"
    # }

    # CodeBuild cache
    # build_cache = {
    #   encrypt = true
    # }
    # CodePipeline deploy
    # deploy = {
    #   encrypt = true
    # }
  }

  kms_key_id = dependency.kms.outputs.key_arn
}
