# Create CodeDeploy deployment group for app running in ASG behind LB

terraform {
  source = "${get_terragrunt_dir()}/../../../modules//codedeploy-deployment-ecs"
}
dependency "iam" {
  config_path = "../iam-codepipeline"
}
dependency "sns" {
  config_path = "../sns-codedeploy-app"
}
dependency "codedeploy-app" {
  config_path = "../codedeploy-app-ecs"
}
 dependency "lb" {
   config_path = "../lb-public"
 }
dependency "target-group-1" {
  config_path = "../target-group-app-ecs-1"
}
dependency "target-group-2" {
  config_path = "../target-group-app-ecs-2"
}
dependency "cluster" {
  config_path = "../ecs-cluster"
}
dependency "service" {
  config_path = "../ecs-service-app"
}
# dependencies {
#   paths = [
#     "../asg-app"
#   ]
# }
include {
  path = find_in_parent_folders()
}

inputs = {
  # Name of component we are deploying
  comp = "app"

  # Name of deployment group, default app-comp-ecs
  # name = "foo-app-ecs"

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-blue-green.html
  target_group_names = [
    dependency.target-group-1.outputs.name,
    dependency.target-group-2.outputs.name
  ]

  listener_arns = [dependency.lb.outputs.listener_arn]

  ecs_cluster_name = dependency.cluster.outputs.name
  ecs_service_name = dependency.service.outputs.name

  # Blue/Green
  deployment_type   = "BLUE_GREEN"
  deployment_option = "WITH_TRAFFIC_CONTROL"

  # On success, deploy immediately
  deployment_ready_option_action_on_timeout     = "CONTINUE_DEPLOYMENT"
  deployment_ready_option_wait_time_in_minutes  = 0

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  # ASG
  # provisioning_action = "DISCOVER_EXISTING"
  # provisioning_action = "COPY_AUTO_SCALING_GROUP"

  # deployment_config_name = "CodeDeployDefault.AllAtOnce"
  # deployment_config_name = "CodeDeployDefault.OneAtATime"

  # In place
  # deployment_type   = "IN_PLACE"
  # deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  # deployment_config_name = "CodeDeployDefault.OneAtATime"

  codedeploy_app_name = dependency.codedeploy-app.outputs.app_name
  codedeploy_service_role_arn = dependency.iam.outputs.codedeploy_service_role_arn

  # alarm_configuration = {
  #   alarms  = ["my-alarm-name"]
  #   enabled = true
  # }

  trigger_target_arn = dependency.sns.outputs.arn
}
