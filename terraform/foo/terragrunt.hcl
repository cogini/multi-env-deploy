# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for
# working with multiple Terraform modules, remote state, and locking:
# https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Configure Terragrunt to store state in S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = join("-", [get_env("ORG", ""), get_env("TF_VAR_app_name", ""), get_env("ENV", "dev"), "tfstate"])
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("TF_VAR_remote_state_s3_bucket_region", "us-east-1")
    dynamodb_table = join("-", [get_env("ORG", ""), get_env("TF_VAR_app_name", ""), "tfstate"])
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are
# automatically merged into the child `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  default_yaml_path = find_in_parent_folders("empty.yml")
  env = get_env("ENV", "dev")
  # org = cogini
  # app_name = foo
  # owner = jake
  # aws_profile = "${local.org}-${local.env}"
}

# This is based on the structure in
# https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
# modified to be more flat.

# Configure root level variables that all resources can inherit. This is
# especially helpful with multi-account configs where terraform_remote_state
# data sources are placed directly into the modules.
inputs = merge(
  yamldecode(
    # Default and common settings
    file("${find_in_parent_folders("common.yml", local.default_yaml_path)}"),
  ),
  yamldecode(
    # Settings for environment
    file("${find_in_parent_folders("${local.env}.yml", local.default_yaml_path)}"),
  ),
  # Use a directory hierarchy to load config files:
  # yamldecode(
  #   file("${get_terragrunt_dir()}/${find_in_parent_folders("env.yml", local.default_yaml_path)}"),
  # ),
  # yamldecode(
  #   file("${get_terragrunt_dir()}/${find_in_parent_folders("region.yml", local.default_yaml_path)}"),
  # ),
  # {
  #   aws_profile = "non-prod"
  # },
)
