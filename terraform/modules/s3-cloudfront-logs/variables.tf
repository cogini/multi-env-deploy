variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "bucket_name" {
  description = "Bucket name, default org_unique-app_name-env.comp"
  default     = ""
}
