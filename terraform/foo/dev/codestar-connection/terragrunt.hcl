# Create CodeStar Connection

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codestar-connection"
}
include {
  path = find_in_parent_folders()
}

inputs = {
  name = "cogini"
  provider_type = "GitHub"
}
