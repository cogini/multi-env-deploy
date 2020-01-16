# Create CodeDeploy deployment for headless worker component in ASG

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codedeploy-deployment-asg"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "sns" {
  config_path = "../sns-codedeploy-app"
}
dependency "codedeploy-app" {
  config_path = "../codedeploy-worker"
}
dependencies {
  paths = [
    "../asg-worker",
  ]
}
include {
  path = find_in_parent_folders()
}

inputs = {
  # Name of component we are deploying
  comp = "worker"

  # Name of deployment group
  name = "foo-worker-asg"

  deployment_type = "IN_PLACE"
  deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # Tag to find the ASG
  deploy_hook = "foo-worker"
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
