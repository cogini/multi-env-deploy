locals {
  # Short name for organization, used to name/tag things
  org        = "cogini"

  # Globally unique name for organization, used for things like S3 buckets
  org_unique = "cogini"

  # Name of the app
  app_name   = "foo"

  # Used to tag resources with the person or group that created them
  owner      = "devops"

}
