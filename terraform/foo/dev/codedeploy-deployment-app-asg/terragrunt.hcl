# Create CodeDeploy deployment group for app running in ASG behind LB

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codedeploy-deployment-asg-app"
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
dependency "target-group" {
  config_path = "../target-group-default"
  # config_path = "../target-group-app"
}
dependencies {
  paths = [
    "../asg-app"
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  # Name of component we are deploying
  comp = "app"

  # Name of deployment group
  name = "foo-app-asg"

  # Tag to find the ASG
  deploy_hook = "foo-app"

  target_group_name = dependency.target-group.outputs.name

  codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
  codedeploy_service_role_arn = dependency.iam.outputs.codedeploy_service_role_arn

  # On success, deploy immediately
  deployment_ready_option_action_on_timeout = "CONTINUE_DEPLOYMENT"
  deployment_ready_option_wait_time_in_minutes = 0

  # alarm_configuration = {
  #   alarms  = ["my-alarm-name"]
  #   enabled = true
  # }

  trigger_target_arn = dependency.sns.outputs.arn
}
