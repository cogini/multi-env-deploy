# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "prod"
  aws_account_id = get_env("AWS_ACCOUNT_ID", "")
  aws_profile    = get_env("AWS_PROFILE", "")
}
