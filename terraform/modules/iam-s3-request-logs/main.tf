# Give load balancer permissions to write to S3 bucket for logs

# https://thepracticalsysadmin.com/configure-s3-to-store-load-balancer-logs-using-terraform/
data "aws_elb_service_account" "main" {
}

data "aws_iam_policy_document" "lb-s3-request-logs" {
  policy_id = "${var.app_name}-lb-s3-request-logs"
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${var.logs_bucket_arn}/${var.logs_bucket_path_prefix}*"
    ]
    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "lb-s3-request-logs" {
  bucket = var.logs_bucket_id
  policy = data.aws_iam_policy_document.lb-s3-request-logs.json
}
