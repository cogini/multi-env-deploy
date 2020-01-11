variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "repo_target_account_ids" {
  description = "AWS account ids which can assume role"
  type        = list(string)
}

variable "role_arn" {
  description = "IAM role which will be assumed"
}
