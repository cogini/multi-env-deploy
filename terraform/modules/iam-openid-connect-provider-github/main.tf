# Create IAM OpenID connect provider for GitHub Action
#
# https://github.com/aws-actions/aws-codebuild-run-build
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
# https://stackoverflow.com/questions/69243571/how-can-i-connect-github-actions-with-aws-deployments-without-using-a-secret-key

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    // original value "sigstore",
    "sts.amazonaws.com", // Used by aws-actions/configure-aws-credentials
  ]
  thumbprint_list = var.thumbprint_list
}
