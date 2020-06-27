# Add IAM policy to instance profile to run pganalyze collector

# Example config:
# terraform {
#   source = "${get_terragrunt_dir()}/../../../modules//iam-pganalyze"
# }
# dependencies {
#   paths = ["../iam-instance-profile-devops"]
# }
# include {
#   path = find_in_parent_folders()
# }
#
# inputs = {
#   comp = "devops"
# }

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.remote_state_s3_bucket_name
    key    = "${var.remote_state_s3_key_prefix}/iam-instance-profile-${var.comp}/terraform.tfstate"
    region = var.remote_state_s3_bucket_region
  }
}

resource "aws_iam_role_policy_attachment" "rds" {
  role       = data.terraform_remote_state.iam.outputs.role_name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

data "aws_iam_policy_document" "log" {
  statement {
    actions = ["rds:DownloadDBLogFilePortion"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "log" {
  name_prefix = "${var.app_name}-${var.comp}-rds-download-db-log-file-portion"
  policy      = data.aws_iam_policy_document.log.json
}

resource "aws_iam_role_policy_attachment" "log" {
  role       = data.terraform_remote_state.iam.outputs.role_name
  policy_arn = aws_iam_policy.log.arn
}
