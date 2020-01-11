# Set up base service roles for CodePipeline

# https://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-service-role.html
resource "aws_iam_role" "codedeploy-service-role" {
  name               = "${var.app_name}-codedeploy-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy-service-role" {
  role       = aws_iam_role.codedeploy-service-role.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# Add permissions needed for CodeDeploy to work with Launch Templates
# https://h2ik.co/2019/02/28/aws-codedeploy-blue-green/
data "aws_iam_policy_document" "launch-templates" {
  statement {
    actions   = ["iam:PassRole", "ec2:CreateTags", "ec2:RunInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "launch-templates" {
  name_prefix = "${var.app_name}-launch-templates"
  description = "Allow access to launch templates"
  policy      = data.aws_iam_policy_document.launch-templates.json
}

resource "aws_iam_role_policy_attachment" "launch-templates" {
  role       = aws_iam_role.codedeploy-service-role.name
  policy_arn = aws_iam_policy.launch-templates.arn
}

resource "aws_iam_role" "codepipeline-service-role" {
  name               = "${var.app_name}-codepipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Allow CodePipeline to read and write S3 bucket encrypted with CMK
resource "aws_kms_grant" "codepipeline" {
  count             = var.kms_key_id != null ? 1 : 0
  name              = "${var.app_name}-codepipeline-app"
  key_id            = var.kms_key_id
  grantee_principal = aws_iam_role.codepipeline-service-role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}

resource "aws_iam_policy" "codebuild-codedeploy" {
  name        = "${var.app_name}-codepipeline-service-role"
  description = "Give CodePipeline rights to run CodeCommit, CodeBuild and CodeDeploy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "iam:PassRole"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "codecommit:CancelUploadArchive",
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:UploadArchive"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline-service-role.name
  policy_arn = aws_iam_policy.codebuild-codedeploy.arn
}

# https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up.html
resource "aws_iam_role" "codebuild-service-role" {
  name               = "${var.app_name}-codebuild"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Allow CodeBuild to read and write S3 bucket encrypted with CMK
resource "aws_kms_grant" "codebuild" {
  count             = var.kms_key_id != null ? 1 : 0
  name              = "${var.app_name}-codebuild-app"
  key_id            = var.kms_key_id
  grantee_principal = aws_iam_role.codebuild-service-role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}

# Allow CodeBuild to write logs to CloudWatch Logs
resource "aws_iam_role_policy" "codebuild-logs" {
  name   = "${var.app_name}-codebuild-logs"
  role   = aws_iam_role.codebuild-service-role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

# Allow CodeBuild to run in a VPC
# https://stackoverflow.com/questions/52843460/receive-not-authorized-to-perform-describesecuritygroups-when-creating-new-pro/52886506
data "aws_iam_policy_document" "codebuild-vpc" {
  statement {
    actions   = [
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codebuild-vpc" {
  name_prefix = "${var.app_name}-codebuild-vpc"
  description = "Allow CodeBuild to run in VPC"
  policy      = data.aws_iam_policy_document.codebuild-vpc.json
}

resource "aws_iam_role_policy_attachment" "codebuild-vpc" {
  role       = aws_iam_role.codebuild-service-role.name
  policy_arn = aws_iam_policy.codebuild-vpc.arn
}
