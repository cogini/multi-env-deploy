# Create Launch Template for app ASG

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//launch-template"
}
dependency "iam" {
  config_path = "../iam-instance-profile-app"
}
dependency "sg" {
  config_path = "../sg-app-private"
}
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  comp = "app"

  image_id = "ami-0d2c61276077f361c"
  instance_type = "t3.nano"

  enable_monitoring = true

  security_group_ids = [dependency.sg.outputs.security_group_id]
  instance_profile_name = dependency.iam.outputs.instance_profile_name
}
