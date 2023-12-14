variable "comp" {
  description = "Component"
}

variable "name" {
  description = "Name of log stream"
  default     = ""
}

variable "domain" {
  description = "Top-level internet domain name for which application has administrative authority"
}

variable "cw_log_enabled" {
  description = "Send copy of telemetry data to CloudWatch Logs"
  default     = null
}

variable "custom_events" {
  description = "Whether web client can define and send custom events: ENABLED or DISABLED (default)"
  default     = null
}

variable "app_monitor_configuration" {
  description = "App monitoring configuration"
  type = object({
    # Set cookies in RUM web client.
    # There are two cookies, a session cookie and a user cookie.
    # The cookies allow the RUM web client to collect data relating to the number
    # of users an application has and the behavior of the application across a
    # sequence of events. Cookies are stored in the top-level domain of the
    # current page.
    allow_cookies = optional(bool),

    # Enable X-Ray tracing for user sessions that RUM samples.
    # RUM adds an X-Ray trace header to allowed HTTP requests and records an
    # X-Ray segment for allowed HTTP requests.
    enable_xray = optional(bool),

    # List of URLs in website or application to exclude from RUM data collection.
    excluded_pages = optional(list(string)),

    # List of pages in CloudWatch RUM console that are to be displayed with a
    # "favorite" icon.
    favorite_pages = optional(list(string)),

    # ARN of guest IAM role attached to the Amazon Cognito identity
    # pool to authorize sending of data to RUM.
    guest_role_arn = optional(string),

    # ID of Amazon Cognito identity pool used to authorize sending data to RUM
    identity_pool_id = optional(string),

    # If app monitor is to collect data from only certain pages in your
    # application, lists those pages
    included_pages = optional(list(string)),

    # Percentage of user sessions to use for RUM data collection. Choosing a
    # higher percentage gives you more data but also incurs more costs. The
    # number you specify is the percentage of user sessions that will be used.
    # Default value is 0.1.
    session_sample_rate = optional(number),

    # Array listing the types of telemetry data to collect.
    # Valid values are "errors", "performance", and "http".
    telemetries = optional(list(string))
  })
  default = null
}
