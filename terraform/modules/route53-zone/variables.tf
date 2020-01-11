variable "name" {
  description = "Name (DNS domain), e.g. example.com"
}

variable "delegation_set_id" {
  description = "Delegation set id"
}

variable "force_destroy" {
  description = "Force destroy even if there are subdomains"
  default     = false
}
