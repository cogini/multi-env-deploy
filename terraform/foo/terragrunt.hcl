# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for
# working with multiple Terraform modules, remote state, and locking:
# https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# This is based on the structure in
# https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
# modified to be more flat.

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region

  # Default and common settings
  common_vars = yamldecode(
    file(find_in_parent_folders("common.yml"))
  )

  org = local.common_vars.org
  app_name = local.common_vars.app_name

  default_yaml_path = find_in_parent_folders("empty.yml")
  env = get_env("ENV", "dev")
  # org = cogini
  # app_name = foo
  # owner = jake
  # aws_profile = "${local.org}-${local.env}"
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  # allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = join("-", [get_env("ORG", ""), get_env("TF_VAR_app_name", ""), get_env("ENV", "dev"), "tfstate"])
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("TF_VAR_remote_state_s3_bucket_region", "us-east-1")
    dynamodb_table = join("-", [get_env("ORG", ""), get_env("TF_VAR_app_name", ""), "tfstate"])
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are
# automatically merged into the child `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

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
