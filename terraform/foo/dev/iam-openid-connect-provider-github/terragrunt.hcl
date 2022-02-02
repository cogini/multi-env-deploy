# Configure IAM role  CodePipeline components

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//iam-openid-connect-provider-github"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  # https://stackoverflow.com/questions/69247498/how-can-i-calculate-the-thumbprint-of-an-openid-connect-server/69247499#69247499
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "a031c46782e6e6c662c2c87c76da9aa62ccabd8e"
  ]
}
