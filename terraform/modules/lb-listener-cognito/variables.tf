variable "loadbalancer_arn" {
  description = "The arn of the load balancer"
}
variable "port" {
  description = "The port of the listener"
}
variable "protocol" {
  description = "The protocol of the listener"
}
variable "enable_acm_cert" {
  description = "Whether to enable creating the listener"
}
variable "dns_domain" {
  description = "The name of the domain"
}
variable "user_pool_arn" {
  description = "Cogito user pool arn"
}
variable "user_pool_client_id" {
  description = "Cogito user pool client app id"
}
variable "user_pool_domain" {
  description = "Cogito user pool domain"
}
variable "target_group_arn" {
  description = "The arn of the target group"
}
