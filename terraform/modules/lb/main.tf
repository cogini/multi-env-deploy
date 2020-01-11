# Create Application Load Balancer

# Example config:

locals {
  name = var.name == "" ? "${var.app_name}-${var.comp}" : var.name
}

locals {
  cert_domain = replace(var.dns_domain, "/\\.$/", "") # dns has trailing dot
}

# Certificate managed by ACM
data "aws_acm_certificate" "acm" {
  count    = var.enable_acm_cert ? 1 : 0
  domain   = local.cert_domain
  statuses = ["ISSUED"]
}

# Certificate managed external to AWS, e.g. in China where ACM is not available
data "aws_iam_server_certificate" "iam" {
  count  = var.enable_iam_cert ? 1 : 0
  name   = local.cert_domain
  latest = true
}

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "this" {
  name     = local.name
  internal = var.internal

  security_groups = var.security_group_ids
  subnets = var.subnet_ids

  access_logs {
    bucket  = var.access_logs_bucket_id
    prefix  = "${var.access_logs_bucket_path_prefix}${local.name}"
    enabled = true
  }

  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  ip_address_type            = var.ip_address_type

  tags = merge(
    {
      "Name"  = local.name
      "org"   = var.org
      "app"   = var.app_name
      "env"   = var.env
      "owner" = var.owner
    },
    var.extra_tags,
  )
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "http" {
  count             = var.enable_http ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "http-https" {
  count             = var.enable_http ? 0 : 1
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https-acm" {
  count             = var.enable_acm_cert ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm[0].arn

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https-iam" {
  count             = var.enable_iam_cert ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_iam_server_certificate.iam[0].arn

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}
