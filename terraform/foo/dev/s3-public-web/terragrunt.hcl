# Create S3 buckets for public website

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//s3-app"
}
# dependency "kms" {
#   config_path = "../kms"
# }
# dependency "route53" {
#   config_path = "../route53-public"
#   # config_path = "../route53-cdn" # separate CDN domain
# }
include {
  path = find_in_parent_folders()
}

inputs = {
  comp = "public"

  # Force S3 buckets to be deleted even when they are not empty
  # This is useful in dev, but dangerous in prod
  force_destroy = true

  buckets = {
    # App assets such as CSS and JS published via CDN
    # assets = {
    #   encrypt = false
    # }
    # Config files
    # config = {
    #   encrypt = true
    # }
    # Data files
    # data = {
    #   encrypt = true
    # }
    # SSM log files
    # ssm = {
    #   encrypt = true
    # }
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

    # App public web, served from CDN
    web = {
    }
  }

  # kms_key_id = dependency.kms.outputs.key_arn
}
