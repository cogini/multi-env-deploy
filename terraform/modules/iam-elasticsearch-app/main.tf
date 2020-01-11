# Give IAM instance profile access to Elasticsearch

locals {
  name = var.name == "" ? var.comp : var.name
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["es:*"]
    resources = [
      "${var.domain_arn}/*",
    ]
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name     = var.domain_name
  access_policies = data.aws_iam_policy_document.this.json
}
