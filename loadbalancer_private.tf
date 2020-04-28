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

  name        = "${var.name}-sg-private"
  description = "Security group for the private ALB"
  vpc_id      = var.vpc_id

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
      Name = var.name
    },
    var.resource_labels
  )
}

# Load balancer (ALB)
resource "aws_lb" "quortex_private" {
  # #name               = "${var.name}-lb-pri"
  # name_prefix        = var.name
  # TODO: name should contain the cluster name, but it is limited to 32 characters
  
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.quortex_private.id}"]
  subnets            = var.subnet_ids

  tags = merge({
      Name = var.name
    },
    var.resource_labels
  )
}

# Target group of the ALB (type IP)
resource "aws_lb_target_group" "quortex_private" {
  # Instances can be attached to this group automatically by specifying 
  # this group id in an autoscaling group.

  # No target group will be created (yet) if the no port is defined
  count       = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  #name        = "${var.name}-target-group-private"
  # TODO: name should contain the cluster name, but it is limited to 32 characters
  vpc_id      = var.vpc_id
  
  target_type = "instance"
  protocol    = "HTTP"
  port        = var.load_balancer_private_app_backend_ports[0]

  tags = merge({
      Name = var.name
    },
    var.resource_labels
  )
}

# Listeners for the ALB

# TLS listener (443)
resource "aws_lb_listener" "quortex_private_tls" {
  # This listener terminates the TLS and forwards traffic in simple HTTP to the target
  # Configured with the certificate created in the ACM service
  
  # No listener will be created (yet) if the no port is defined
  count             = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_private.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # this is the default policy (allows TLSv1 TLSv1.1 TLSv1.2)
  certificate_arn   = var.load_balancer_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_private[count.index].arn
  }
}

# HTTP listener (80)
resource "aws_lb_listener" "quortex_private_http" {
  # This listener forwards traffic as-is to the target

  # No listener will be created (yet) if the no port is defined
  count             = length(var.load_balancer_private_app_backend_ports) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.quortex_private.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quortex_private[count.index].arn
  }
}