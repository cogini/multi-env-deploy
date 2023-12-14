# Create SQS queue for component

# Example config:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//sqs"
# }
# include {
#   path = find_in_parent_folders()
# }
# inputs = {
#   name = "dt"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue.html
resource "aws_sns_topic" "this" {
  name = var.name
  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "comp"  = var.comp
      "owner" = var.owner
    },
    var.extra_tags
  )
}
