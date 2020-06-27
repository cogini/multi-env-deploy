variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "bucket_prefix" {
  description = "Start of bucket name, default org_unique-app_name-env.comp"
  default     = ""
}

variable "buckets" {
  description = "Buckets to create"
  type        = map
  default     = {}
}

variable "force_destroy" {
  description = "Force destroy of bucket even if it's not empty"
  default     = false
}

variable "cors_allowed_headers" {
  type    = list
  default = ["*"]
}

variable "cors_allowed_methods" {
  type    = list
  default = ["GET"]
}

variable "cors_allowed_origins" {
  type    = list
  default = ["*"]
}

variable "cors_expose_headers" {
  type    = list
  default = ["ETag"]
}

variable "cors_max_age_seconds" {
  default = "3600"
}

variable "kms_key_id" {
  description = "Custom KMS key ARN"
  default     = null
}

variable "sse_algorithm" {
  description = "Encryption algorithm. aws:kms or AES256"
  default     = "aws:kms"
}
