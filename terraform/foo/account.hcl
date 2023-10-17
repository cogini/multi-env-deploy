locals {
  # aws_account_name   = "prod"
  aws_account_id = get_env("AWS_ACCOUNT_ID", "")
  aws_profile    = get_env("AWS_PROFILE", "")
}
