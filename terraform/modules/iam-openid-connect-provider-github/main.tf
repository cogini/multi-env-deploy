# Create IAM OpenID connect provider for GitHub Action

# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider

# Get the latest TLS cert from GitHub to authenticate their requests
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC Provider in the AWS Account
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"
#   client_id_list = [
#     // original value "sigstore",
#     "sts.amazonaws.com", // Used by aws-actions/configure-aws-credentials
#   ]
#   thumbprint_list = var.thumbprint_list
# }
