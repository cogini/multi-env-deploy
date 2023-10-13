variable "comp" {
  description = "Name of the component, app, worker, etc."
  default     = "public"
}

variable "name" {
  description = "Name of the instance, var.app_name-var.comp if blank"
  default     = ""
}

variable "dns_domain" {
  description = "DNS domain name, used to find certs"
  default     = ""
}

variable "enable_acm_cert" {
  description = "Use AWS Certificate Manager to manage cert"
  default     = true
}

variable "enable_iam_cert" {
  description = "Use IAM to manage cert, exclusive to enable_acm_certificate"
  default     = false
}

variable "enable_http" {
  description = "Enable unencrypted HTTP"
  default     = false
}

variable "target_group_arn" {
  description = "Default Target Group ARN"
}

# LB params
variable "internal" {
  description = "Whether LB is internal or public"
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet ids"
  type        = list(any)
}

variable "security_group_ids" {
  description = "List of security group ids"
  type        = list(any)
}

variable "access_logs_bucket_id" {
  description = "S3 bucket for logs"
}
variable "access_logs_bucket_path_prefix" {
  description = "S3 bucket prefix"
  default     = "lb/"
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer"
  default     = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"

  # default     = "dualstack"
  default = "ipv4"
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
variable "ssl_policy" {
  description = "SSL security policy"
  default     = null
}
