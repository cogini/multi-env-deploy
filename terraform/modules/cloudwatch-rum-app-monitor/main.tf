# Create CloudWatch RUM (Real User Monitoring) App Monitor

# Example:
# terraform {
#   source = "${dirname(find_in_parent_folders())}/modules//cloudwatch-rum-app-monitor"
# }
# 
# dependency "identity-pool" {
#   config_path = "../cognito-identity-pool-unauth"
# }
# 
# dependency "role" {
#   config_path = "../iam-cognito-client-role-unauth"
# }
# 
# dependency "route53" {
#   config_path = "../route53-public"
# }
# 
# include "root" {
#   path = find_in_parent_folders()
# }
# 
# inputs = {
#   # name = "foo" # Default is app_name-comp
#   comp = "app"
# 
#   domain = dependency.route53.outputs.name
# 
#   # Send copy of telemetry data to CloudWatch Logs
#   # cw_log_enabled = true
# 
#   # Whether web client can define and send custom events
#   # custom_events = "ENABLED"
# 
#   app_monitor_configuration = {
#     # Set cookies in RUM web client.
#     # The client sets two cookies, a session cookie and a user cookie. The
#     # cookies allow the RUM web client to collect data relating to the number
#     # of users an application has and the behavior of the application across a
#     # sequence of events. Cookies are stored in the top-level domain of the
#     # current page.
#     allow_cookies = true
# 
#     # Enable X-Ray tracing for user sessions that RUM samples.
#     # RUM adds an X-Ray trace header to allowed HTTP requests and records an
#     # X-Ray segment for allowed HTTP requests.
#     enable_xray = true
# 
#     # List of URLs in your website or application to exclude from RUM data collection
#     # excluded_pages = []
# 
#     # List of pages in CloudWatch RUM console that are to be displayed with a
#     # "favorite" icon
#     # favorite_pages = []
# 
#     # ARN of guest IAM role attached to the Amazon Cognito identity
#     # pool to authorize sending of data to RUM
#     guest_role_arn = dependency.role.outputs.arn
# 
#     # ID of Amazon Cognito identity pool used to authorize sending data to RUM
#     identity_pool_id = dependency.identity-pool.outputs.id
# 
#     # If app monitor is to collect data from only certain pages in your
#     # application, lists those pages
#     # included_pages = []
# 
#     # Percentage of user sessions to use for RUM data collection. Choosing a
#     # higher percentage gives you more data but also incurs more costs. The
#     # number you specify is the percentage of user sessions that will be used.
#     # Default value is 0.1.
#     # session_sample_rate = 0.1
# 
#     # Array listing the types of telemetry data to collect.
#     # Valid values are "errors", "performance", and "http".
#     telemetries = ["errors", "performance", "http"]
#   }
# }

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rum_app_monitor
resource "aws_rum_app_monitor" "this" {
  name   = local.name
  domain = var.domain

  cw_log_enabled = var.cw_log_enabled

  dynamic "custom_events" {
    for_each = var.custom_events == null ? [] : tolist([1])
    content {
      status = var.custom_events
    }
  }

  dynamic "app_monitor_configuration" {
    for_each = var.app_monitor_configuration == null ? [] : tolist([1])
    content {
      allow_cookies       = lookup(var.app_monitor_configuration, "allow_cookies", null)
      enable_xray         = lookup(var.app_monitor_configuration, "enable_xray", null)
      excluded_pages      = lookup(var.app_monitor_configuration, "excluded_pages", null)
      favorite_pages      = lookup(var.app_monitor_configuration, "favorite_pages", null)
      guest_role_arn      = lookup(var.app_monitor_configuration, "guest_role_arn", null)
      identity_pool_id    = lookup(var.app_monitor_configuration, "identity_pool_id", null)
      included_pages      = lookup(var.app_monitor_configuration, "included_pages", null)
      session_sample_rate = lookup(var.app_monitor_configuration, "session_sample_rate", null)
      telemetries         = lookup(var.app_monitor_configuration, "telemetries", null)
    }
  }

  tags = merge(
    {
      "Name"  = format("%s-%s", var.app_name, var.env)
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}
