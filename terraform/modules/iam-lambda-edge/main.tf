# Create IAM service role for Lambda@Edge

# https://qiita.com/maruware/items/557ff3c11a45d5414cea

data "aws_iam_policy_document" "lambda-edge-service-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-edge" {
  name               = "${var.app_name}-lambda-edge-service-role"
  assume_role_policy = data.aws_iam_policy_document.lambda-edge-service-role.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda-edge.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda-edge-cloudwatch-logs" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:${var.aws_partition}:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "lambda-edge-cloudwatch-logs" {
  name   = "${var.app_name}-lambda-edge-cloudwatch-logs"
  role   = aws_iam_role.lambda-edge.name
  policy = data.aws_iam_policy_document.lambda-edge-cloudwatch-logs.json
}
