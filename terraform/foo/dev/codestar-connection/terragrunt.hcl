# Create CodeStar Connection

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//codestar-connection"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  name = "cogini"
  provider_type = "GitHub"
}
