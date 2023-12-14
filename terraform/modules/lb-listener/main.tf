# Create Application Load Balancer

# Example config:

locals {
  cert_domain = replace(var.dns_domain, "/\\.$/", "") # dns has trailing dot
}

# Certificate managed by ACM
data "aws_acm_certificate" "acm" {
  count    = var.enable_acm_cert ? 1 : 0
  domain   = local.cert_domain
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "https" {
  count             = var.enable_acm_cert ? 1 : 0
  load_balancer_arn = var.loadbalancer_arn
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm[0].arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}
