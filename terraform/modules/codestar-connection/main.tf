# Create a CD pipeline with CodePipeline, CodeBuild, CodeDeploy.

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//codestar-connection"
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   name = "cogini"
#   provider_type = "GitHub"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection
# https://www.oasys.net/posts/connecting-github-to-sns-using-codepipeline/
resource "aws_codestarconnections_connection" "this" {
  name          = var.name
  provider_type = var.provider_type

  tags = merge(
    {
      "Name"  = var.name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}
