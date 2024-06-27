variable "name" {
  description = "Cognito identity pool name"
  default     = ""
}

variable "comp" {
  description = "Name of the app component, app, worker, etc."
}

variable "allow_unauthenticated_identities" {
  description = "Allow unauthenticated identities in identity pool"
  default     = false
}
