/**
 * Copyright 2020 Quortex
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


# There are 3 types of load balancers in AWS:
# - Classic
# - NLB (Network Load Balancer)
# - ALB (Application Load Balancer)
#
# Here an Application Load Balancer is created.
# It listens for HTTP and HTTPS, and forwards HTTPS to instances of the
# target group.
# The target group is made of instances, which are the instances of the
# autoscaling group.


locals {
  # Important note: the default quota for "Inbound or outbound rules per security group" is 60, it is not sufficient to fit all the Cloudfront IP ranges. This quota should be increased in the region used.
  public_lb_allowed_ip_ranges                       = toset(var.load_balancer_public_restrict_ip_access ? var.load_balancer_public_whitelisted_ips : ["0.0.0.0/0"])
  load_balancer_public_whitelisted_token_ips_chunks = chunklist(var.load_balancer_public_whitelisted_token_ips, 5)
}

# Security group
resource "aws_security_group" "quortex_public" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  name        = local.public_lb_security_group_name
  description = "Security group for the public ALB"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = local.public_lb_security_group_name
    },
    var.tags
  )
}

# Security group rules
resource "aws_vpc_security_group_ingress_rule" "lb_public_http" {
  for_each = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_http ? local.public_lb_allowed_ip_ranges : []

  description       = "Allow simple HTTP from whitelisted ip ranges only"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.quortex_public[0].id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "lb_public_https" {
  for_each = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_https ? local.public_lb_allowed_ip_ranges : []

  description       = "Allow TLS HTTP from whitelisted ip ranges only"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.quortex_public[0].id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "lb_public_http_prefix_list" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_http && var.load_balancer_public_restrict_ip_access ? length(var.load_balancer_public_whitelisted_prefix_lists) : 0

  description       = "Allow simple HTTP from given prefix list"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  prefix_list_id    = var.load_balancer_public_whitelisted_prefix_lists[count.index]
  security_group_id = aws_security_group.quortex_public[0].id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "lb_public_https_prefix_list" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_https && var.load_balancer_public_restrict_ip_access ? length(var.load_balancer_public_whitelisted_prefix_lists) : 0

  description       = "Allow TLS HTTP from from given prefix list"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = var.load_balancer_public_whitelisted_prefix_lists[count.index]
  security_group_id = aws_security_group.quortex_public[0].id

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "lb_public_egress" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  description       = "Allow all traffic out"
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.quortex_public[0].id

  tags = var.tags
}


# Load balancer (ALB)
resource "aws_lb" "quortex_public" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  name = local.public_lb_name

  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.quortex_public[0].id]
  subnets            = var.subnet_ids

  # Access logs storage in s3
  access_logs {
    enabled = var.public_lb_access_logs_enabled
    bucket  = aws_s3_bucket.public_lb_access_logs[0].bucket
    prefix  = var.public_lb_access_logs_bucket_prefix
  }

  # Advanced parameters
  idle_timeout = var.public_lb_idle_timeout

  tags = merge({
    Name = local.public_lb_name
    },
    var.public_tags,
    var.tags
  )
  depends_on = [
    aws_s3_bucket_policy.public_lb_access_logs
  ]
}

# Target group of the ALB (type IP)
resource "aws_lb_target_group" "quortex_public" {
  # Instances can be attached to this group automatically by specifying
  # this group id in an autoscaling group.

  # No target group will be created if the target port is not defined
  count = length(var.load_balancer_public_app_backend_ports)

  vpc_id = var.vpc_id

  target_type = "instance"
  protocol    = "HTTP"
  port        = var.load_balancer_public_app_backend_ports[count.index]

  deregistration_delay          = var.public_lb_deregistration_delay
  slow_start                    = var.public_lb_slow_start
  load_balancing_algorithm_type = var.public_lb_load_balancing_algorithm_type

  stickiness {
    type            = var.public_lb_stickiness_type
    cookie_duration = var.public_lb_stickiness_cookie_duration
    enabled         = var.public_lb_stickiness_enabled
  }

  health_check {
    enabled             = var.public_lb_health_check_enabled
    interval            = var.public_lb_health_check_interval
    path                = var.public_lb_health_check_path
    port                = length(var.public_lb_health_check_ports) > 0 ? var.public_lb_health_check_ports[count.index] : var.public_lb_health_check_port
    protocol            = var.public_lb_health_check_protocol
    timeout             = var.public_lb_health_check_timeout
    healthy_threshold   = var.public_lb_health_check_healthy_threshold
    unhealthy_threshold = var.public_lb_health_check_unhealthy_threshold
    matcher             = var.public_lb_health_check_matcher
  }

  tags = merge({
    Name = local.public_lb_target_group_name
    },
    var.tags
  )

  # workaround for failing target group modifications
  lifecycle {
    create_before_destroy = true
  }
}

# Listeners for the ALB

# TLS listener (443)
resource "aws_lb_listener" "quortex_public_tls" {
  # This listener terminates the TLS and forwards traffic in simple HTTP to the target
  # Configured with the certificate created in the ACM service

  # No listener will be created (yet) if the target port is not defined
  count = var.load_balancer_public_expose_https && length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_public[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.public_lb_ssl_policy
  certificate_arn   = var.ssl_certificate_arn == null ? aws_acm_certificate_validation.cert[0].certificate_arn : var.ssl_certificate_arn

  dynamic "default_action" {
    for_each = var.load_balancer_public_restrict_token_access ? [1] : []

    content {
      type = "fixed-response"
      fixed_response {
        status_code  = 403
        content_type = "text/plain"
        message_body = "403 Forbidden"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.load_balancer_public_restrict_token_access ? [] : [1]

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.quortex_public[count.index].arn
    }
  }

  tags = merge({
    Name = local.public_lb_tls_listener_name
    },
    var.tags
  )
}

# Provides Load Balancer Listener Certificate resources.
# These resources are for additional certificates whose ARNs were passed in the load_balancer_public_additional_certs_arns variable and does not replace the default certificate on the listener.
resource "aws_lb_listener_certificate" "quortex_public" {
  for_each = var.load_balancer_public_expose_https && length(var.load_balancer_public_app_backend_ports) > 0 ? var.load_balancer_public_additional_certs_arns : []

  listener_arn    = aws_lb_listener.quortex_public_tls[0].arn
  certificate_arn = each.value
}

# Provides Load Balancer Listener Certificate resources.
# These resources are for an additional certificate created by this module, whose hotnames were passed in the load_balancer_public_additional_certs_hostnames variable and does not replace the default certificate on the listener.
resource "aws_lb_listener_certificate" "quortex_public_additional" {
  for_each = var.load_balancer_public_expose_https && length(var.load_balancer_public_app_backend_ports) > 0 ? {for index, cert in aws_acm_certificate.additional_cert_public: index => cert} : {}

  listener_arn    = aws_lb_listener.quortex_public_tls[0].arn
  certificate_arn = each.value.arn
}

resource "aws_lb_listener_rule" "quortex_public_tls_token_rule" {
  # This rule forwards traffic if the header token match the condition
  count = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_https ? 1 : 0

  listener_arn = aws_lb_listener.quortex_public_tls[0].arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_public[0].arn
  }

  condition {
    http_header {
      http_header_name = "x-auth-token"
      values           = [var.load_balancer_public_token]
    }
  }

  lifecycle {
    ignore_changes = [
      condition
    ]
  }

  tags = merge({
    Name = local.public_lb_tls_listener_rule_token_name
    },
    var.tags
  )
}

resource "aws_lb_listener_rule" "quortex_public_tls_whitelist_rule" {
  # This rule forwards traffic if the ips are in the whitelist
  count = var.load_balancer_public_expose_https && var.load_balancer_public_restrict_token_access ? length(local.load_balancer_public_whitelisted_token_ips_chunks) : 0

  listener_arn = aws_lb_listener.quortex_public_tls[0].arn
  priority     = 10000 + count.index

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_public[0].arn
  }

  condition {
    source_ip {
      values = local.load_balancer_public_whitelisted_token_ips_chunks[count.index]
    }
  }

  tags = merge({
    Name = local.public_lb_tls_listener_rule_whitelist_name
    },
    var.tags
  )
}

# HTTP listener (80)
resource "aws_lb_listener" "quortex_public_http" {
  # This listener forwards traffic as-is to the target

  # No listener will be created (yet) if the no port is defined
  count = var.load_balancer_public_expose_http && length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_public[0].arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.load_balancer_public_redirect_http_to_https ? [1] : []

    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = !var.load_balancer_public_redirect_http_to_https && var.load_balancer_public_restrict_token_access ? [1] : []

    content {
      type = "fixed-response"
      fixed_response {
        status_code  = 403
        content_type = "text/plain"
        message_body = "403 Forbidden"
      }
    }
  }

  dynamic "default_action" {
    for_each = !var.load_balancer_public_redirect_http_to_https && !var.load_balancer_public_restrict_token_access ? [1] : []

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.quortex_public[count.index].arn
    }
  }

  tags = merge({
    Name = local.public_lb_http_listener_name
    },
    var.tags
  )
}

resource "aws_lb_listener_rule" "quortex_public_http_token_rule" {
  # This rule forwards traffic if the header token match the condition
  count = length(var.load_balancer_public_app_backend_ports) > 0 && var.load_balancer_public_expose_http ? 1 : 0

  listener_arn = aws_lb_listener.quortex_public_http[0].arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_public[0].arn
  }

  condition {
    http_header {
      http_header_name = "x-auth-token"
      values           = [var.load_balancer_public_token]
    }
  }

  lifecycle {
    ignore_changes = [
      condition
    ]
  }

  tags = merge({
    Name = local.public_lb_http_listener_rule_token_name
    },
    var.tags
  )
}

resource "aws_lb_listener_rule" "quortex_public_http_whitelist_rule" {
  # This rule forwards traffic if the ips are in the whitelist
  count = var.load_balancer_public_expose_http && var.load_balancer_public_restrict_token_access ? length(local.load_balancer_public_whitelisted_token_ips_chunks) : 0

  listener_arn = aws_lb_listener.quortex_public_http[0].arn
  priority     = 10000 + count.index

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_public[0].arn
  }

  condition {
    source_ip {
      values = local.load_balancer_public_whitelisted_token_ips_chunks[count.index]
    }
  }

  tags = merge({
    Name = local.public_lb_http_listener_rule_whitelist_name
    },
    var.tags
  )
}

# Public ELB access logs bucket configuration
resource "aws_s3_bucket" "public_lb_access_logs" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  bucket        = var.public_lb_access_logs_bucket_name != "" ? var.public_lb_access_logs_bucket_name : "${var.resource_name}-public-lb-access-logs"
  force_destroy = var.public_lb_access_logs_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "public_lb_access_logs" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 && var.public_lb_access_logs_expiration != null ? 1 : 0

  bucket = aws_s3_bucket.public_lb_access_logs[0].id
  rule {
    id     = "expiration"
    status = "Enabled"
    expiration {
      days = var.public_lb_access_logs_expiration
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_lb_access_logs" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  bucket = aws_s3_bucket.public_lb_access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Set minimal encryption on buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "public_lb_access_logs" {
  count  = length(var.load_balancer_public_app_backend_ports) > 0 && var.public_lb_access_logs_bucket_encryption ? 1 : 0
  bucket = aws_s3_bucket.public_lb_access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "public_lb_access_logs" {
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? 1 : 0
  bucket = aws_s3_bucket.public_lb_access_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.public_lb_access_logs[0].bucket}/*"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.public_lb_access_logs[0].bucket}/*",
      }
    ]
  })
}
