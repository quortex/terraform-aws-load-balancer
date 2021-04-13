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


# Security group
resource "aws_security_group" "quortex_private" {
  name        = local.private_lb_security_group_name
  description = "Security group for the private ALB"

  vpc_id = var.vpc_id

  ingress {
    description = "Allow TLS HTTP from whitelisted ip ranges only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.load_balancer_private_whitelisted_ips
  }

  ingress {
    description = "Allow simple HTTP from whitelisted ip ranges only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.load_balancer_private_whitelisted_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = local.private_lb_security_group_name
    },
    var.tags
  )
}

# Load balancer (ALB)
resource "aws_lb" "quortex_private" {
  name = local.private_lb_name

  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.quortex_private.id]
  subnets            = var.subnet_ids

  # Advanced parameters
  idle_timeout = var.private_lb_idle_timeout

  tags = merge({
    Name = local.private_lb_name
    },
    var.tags
  )
}

# Target group of the ALB (type IP)
resource "aws_lb_target_group" "quortex_private" {
  # Instances can be attached to this group automatically by specifying 
  # this group id in an autoscaling group.

  # No target group will be created (yet) if the no port is defined
  count = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  vpc_id = var.vpc_id

  target_type = "instance"
  protocol    = "HTTP"
  port        = var.load_balancer_private_app_backend_ports[0]

  deregistration_delay          = var.private_lb_deregistration_delay
  slow_start                    = var.private_lb_slow_start
  load_balancing_algorithm_type = var.private_lb_load_balancing_algorithm_type

  stickiness {
    type            = var.private_lb_stickiness_type
    cookie_duration = var.private_lb_stickiness_cookie_duration
    enabled         = var.private_lb_stickiness_enabled
  }

  health_check {
    enabled             = var.private_lb_health_check_enabled
    interval            = var.private_lb_health_check_interval
    path                = var.private_lb_health_check_path
    port                = var.private_lb_health_check_port
    protocol            = var.private_lb_health_check_protocol
    timeout             = var.private_lb_health_check_timeout
    healthy_threshold   = var.private_lb_health_check_healthy_threshold
    unhealthy_threshold = var.private_lb_health_check_unhealthy_threshold
    matcher             = var.private_lb_health_check_matcher
  }

  tags = merge({
    Name = local.private_lb_target_group_name
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
resource "aws_lb_listener" "quortex_private_tls" {
  # This listener terminates the TLS and forwards traffic in simple HTTP to the target
  # Configured with the certificate created in the ACM service

  # No listener will be created (yet) if the no port is defined
  count = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_private.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.private_lb_ssl_policy
  certificate_arn   = var.ssl_certificate_arn == null ? values(aws_acm_certificate_validation.cert)[0].certificate_arn : var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_private[count.index].arn
  }
}

# HTTP listener (80)
resource "aws_lb_listener" "quortex_private_http" {
  # This listener forwards traffic as-is to the target

  # No listener will be created (yet) if the no port is defined
  count = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_private.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_private[count.index].arn
  }
}
