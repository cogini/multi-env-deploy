# Create CodeDeploy deployment group for app running in EC2

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//codedeploy-deployment-ec2"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "sns" {
  config_path = "../sns-codedeploy-app"
}
dependency "codedeploy-app" {
  config_path = "../codedeploy-app"
}
dependencies {
  paths = [
    "../ec2-app",
    # "../iam-codepipeline-app",
  ]
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # Name of component we are deploying
  comp = "app"

  # Name of deployment group
  name = "foo-app-ec2"

  ec2_tag_filter = [
    {
      key   = "deploy_hook"
      type  = "KEY_AND_VALUE"
      value = "foo-app-ec2"
    }
  ]

  # ec2_tag_set {
  #   ec2_tag_filter {
  #     key   = "Name"
  #     type  = "KEY_AND_VALUE"
  #     value = "foo-dev-app-test"
  #   }
  # }

  # alarm_configuration = {
  #   alarms  = ["my-alarm-name"]
  #   enabled = true
  # }

  trigger_target_arn = dependency.sns.outputs.arn
  codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
  codedeploy_service_role_arn = dependency.iam.outputs.codedeploy_service_role_arn
}
