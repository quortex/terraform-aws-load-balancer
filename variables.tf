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

variable "private_lb_security_group_name" {
  type        = string
  description = "Name of the security group for the private ALB"
  default     = "quortex-private"
}

variable "private_lb_name" {
  type        = string
  description = "Name of the private ALB"
  default     = "quortex-private"
}

variable "private_lb_target_group_name" {
  type        = string
  description = "Name of the private ALB target group name"
  default     = "quortex-private"
}

variable "public_lb_security_group_name" {
  type        = string
  description = "Name of the security group for the public ALB"
  default     = "quortex-public"
}

variable "public_lb_name" {
  type        = string
  description = "Name of the public ALB"
  default     = "quortex-public"
}

variable "public_lb_target_group_name" {
  type        = string
  description = "Name of the public ALB target group name"
  default     = "quortex-public"
}

variable "ssl_certificate_name" {
  type        = string
  description = "Name of the SSL certificate"
  default     = "quortex"
}

variable "region" {
  type        = string
  description = "The region in wich to create load balancers."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which the ALB should be."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets (worker node subnets)"
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks of the subnets"
}

variable "cluster_security_group_id" {
  type        = string
  description = "ID of the cluster security group created by EKS. Rules will be added to it, to allow traffic to the backend nodeports (restricted to the subnet cidr)."
}

variable "load_balancer_public_app_backend_ports" {
  type        = list(number)
  description = "The port number on which backend instances are listening"
}

variable "load_balancer_private_app_backend_ports" {
  type        = list(number)
  description = "The port number on which backend instances are listening"
}

variable "load_balancer_private_whitelisted_ips" {
  type        = list(string)
  description = "A list of IP ranges to whitelist for private access."
  default     = []
}

variable "load_balancer_autoscaling_group_names" {
  type        = list(string)
  description = "The name of the autoscaling groups containing the target instances, so that instances can be attached to the load balancer's target group."
}

variable "dns_hosted_zone_id" {
  type        = string
  description = "The ID of the hosted zone in Route53, under which the DNS record should be created."
}

variable "dns_records_private" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for private endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "dns_records_public" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for public endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "ssl_certificate_subdomain" {
  type        = string
  description = "The subdomain name that will be written in the TLS certificate. Can include a wildcard. The hosted zone name will be appended to form the complete domain name."
}

variable "tags" {
  type        = map
  description = "The tags (a map of key/value pairs) to be applied to created resources."
  default     = {}
}

/** Advanced Load balancer params */

/* Load balancer params */

variable "private_lb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application."
  default     = 60
}

/* Listener params */

variable "private_lb_ssl_policy" {
  type        = string
  description = "The name of the SSL Policy for the listener. Required if protocol is HTTPS or TLS."
  default     = "ELBSecurityPolicy-2016-08"
}

/* Target params */

variable "private_lb_deregistration_delay" {
  type        = number
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = 300
}

variable "private_lb_slow_start" {
  type        = number
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds."
  default     = 0
}

variable "private_lb_load_balancing_algorithm_type" {
  type        = string
  description = "Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is round_robin or least_outstanding_requests. The default is round_robin."
  default     = "round_robin"
}

/* Stickiness */

variable "private_lb_stickiness_type" {
  type        = string
  description = "The type of sticky sessions. The only current possible value is lb_cookie."
  default     = "lb_cookie"
}

variable "private_lb_stickiness_cookie_duration" {
  type        = number
  description = " The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)."
  default     = 86400
}

variable "private_lb_stickiness_enabled" {
  type        = bool
  description = "Boolean to enable / disable stickiness. Default is true"
  default     = true
}

/* Health check */

variable "private_lb_health_check_enabled" {
  type        = bool
  description = "Indicates whether health checks are enabled. Defaults to true."
  default     = true
}

variable "private_lb_health_check_interval" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target  groups, it needs to be greater as the timeout of the underlying lambda. Default 30 seconds."
  default     = 30
}

variable "private_lb_health_check_path" {
  type        = string
  description = "The destination for the health check request."
}

variable "private_lb_health_check_port" {
  type        = string
  description = "The port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port."
  default     = "traffic-port"
}

variable "private_lb_health_check_protocol" {
  type        = string
  description = "The protocol to use to connect with the target. Defaults to HTTP."
  default     = "HTTP"
}

variable "private_lb_health_check_timeout" {
  type        = number
  description = "The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds, and the default is 5 seconds for the instance target type"
  default     = 5
}


variable "private_lb_health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  default     = 3
}


variable "private_lb_health_check_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering the target unhealthy . For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3."
  default     = 3
}

variable "private_lb_health_check_matcher" {
  type        = string
  description = " (Required for HTTP/HTTPS ALB) The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
}


/* Load balancer params */

variable "public_lb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application."
  default     = 60
}

/* Listener params */

variable "public_lb_ssl_policy" {
  type        = string
  description = "The name of the SSL Policy for the listener. Required if protocol is HTTPS or TLS."
  default     = "ELBSecurityPolicy-2016-08"
}

/* Target params */

variable "public_lb_deregistration_delay" {
  type        = number
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds."
  default     = 300
}

variable "public_lb_slow_start" {
  type        = number
  description = "The amount time for targets to warm up before the load balancer sends them a full share of requests. The range is 30-900 seconds or 0 to disable. The default value is 0 seconds."
  default     = 0
}

variable "public_lb_load_balancing_algorithm_type" {
  type        = string
  description = "Determines how the load balancer selects targets when routing requests. Only applicable for Application Load Balancer Target Groups. The value is round_robin or least_outstanding_requests. The default is round_robin."
  default     = "round_robin"
}

/* Stickiness */

variable "public_lb_stickiness_type" {
  type        = string
  description = "The type of sticky sessions. The only current possible value is lb_cookie."
  default     = "lb_cookie"
}

variable "public_lb_stickiness_cookie_duration" {
  type        = number
  description = " The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)."
  default     = 86400
}

variable "public_lb_stickiness_enabled" {
  type        = bool
  description = "Boolean to enable / disable stickiness. Default is true"
  default     = true
}

/* Health check */

variable "public_lb_health_check_enabled" {
  type        = bool
  description = "Indicates whether health checks are enabled. Defaults to true."
  default     = true
}

variable "public_lb_health_check_interval" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. For lambda target  groups, it needs to be greater as the timeout of the underlying lambda. Default 30 seconds."
  default     = 30
}

variable "public_lb_health_check_path" {
  type        = string
  description = "The destination for the health check request."
}

variable "public_lb_health_check_port" {
  type        = string
  description = "The port to use to connect with the target. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port."
  default     = "traffic-port"
}

variable "public_lb_health_check_protocol" {
  type        = string
  description = "The protocol to use to connect with the target. Defaults to HTTP."
  default     = "HTTP"
}

variable "public_lb_health_check_timeout" {
  type        = number
  description = "The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds, and the default is 5 seconds for the instance target type"
  default     = 5
}


variable "public_lb_health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy. Defaults to 3."
  default     = 3
}


variable "public_lb_health_check_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering the target unhealthy . For Network Load Balancers, this value must be the same as the healthy_threshold. Defaults to 3."
  default     = 3
}

variable "public_lb_health_check_matcher" {
  type        = string
  description = " (Required for HTTP/HTTPS ALB) The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
}
