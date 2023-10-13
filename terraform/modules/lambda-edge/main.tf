# Set up Lambda@Edge functions for CloudFront

# https://qiita.com/maruware/items/557ff3c11a45d5414cea

data "archive_file" "index_html" {
  type        = "zip"
  source_dir  = "lambda/index_html"
  output_path = "lambda/dst/index_html.zip"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function.html
resource "aws_lambda_function" "index_html" {
  # Lambda@Edge functions need to deployed in us-east-1 region
  # provider = aws.cloudfront

  filename         = data.archive_file.index_html.output_path
  function_name    = "${var.app_name}-index_html"
  role             = var.service_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.index_html.output_base64sha256
  runtime          = var.runtime

  publish = true

  memory_size = 128
  timeout     = 3
}
