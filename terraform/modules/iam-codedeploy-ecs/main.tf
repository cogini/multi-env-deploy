# Set up base service roles for CodeDeploy

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

# https://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-service-role.html
resource "aws_iam_role_policy_attachment" "codedeploy-service-role-ecs" {
  role       = aws_iam_role.codedeploy-service-role.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/AWSCodeDeployRoleForECS"
}
