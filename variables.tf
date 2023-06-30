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

variable "resource_name" {
  type        = string
  description = "A name from which the name of the resources will be chosen. Note that each resource name can be set individually."
  default     = "quortex"
}

variable "private_lb_security_group_name" {
  type        = string
  description = "Name of the security group for the private ALB"
  default     = ""
}

variable "private_lb_name" {
  type        = string
  description = "Name of the private ALB"
  default     = ""
}

variable "private_lb_target_group_name" {
  type        = string
  description = "Name of the private ALB target group name"
  default     = ""
}

variable "public_lb_security_group_name" {
  type        = string
  description = "Name of the security group for the public ALB"
  default     = ""
}

variable "public_lb_name" {
  type        = string
  description = "Name of the public ALB"
  default     = ""
}

variable "public_lb_target_group_name" {
  type        = string
  description = "Name of the public ALB target group name"
  default     = ""
}

variable "public_lb_tls_listener_name" {
  type        = string
  description = "Name of the public ALB TLS listener"
  default     = ""
}

variable "public_lb_tls_listener_rule_token_name" {
  type        = string
  description = "Name of the public ALB TLS listener rule with token authorization"
  default     = ""
}

variable "public_lb_tls_listener_rule_whitelist_name" {
  type        = string
  description = "Name of the public ALB TLS listener rule with ip authorization"
  default     = ""
}

variable "public_lb_http_listener_name" {
  type        = string
  description = "Name of the public ALB HTTP listener"
  default     = ""
}

variable "public_lb_http_listener_rule_token_name" {
  type        = string
  description = "Name of the public ALB HTTP listener rule with token authorization"
  default     = ""
}

variable "public_lb_http_listener_rule_whitelist_name" {
  type        = string
  description = "Name of the public ALB HTTP listener rule with ip authorization"
  default     = ""
}

variable "ssl_certificate_name" {
  type        = string
  description = "Name of the SSL certificate.  Not used if an existing certificate ARN is provided."
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which the ALB should be."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets in which to place the load balancers (public subnets)"
}

variable "access_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow in the target group security group."
}

variable "cluster_security_group_id" {
  type        = string
  description = "ID of the cluster security group created by EKS. Rules will be added to it, to allow traffic to the backend nodeports (restricted to the subnet cidr)."
}

variable "load_balancer_public_expose_http" {
  type        = bool
  default     = true
  description = "Set to true if the HTTP port 80 should be exposed (for the public load balancer)"
}

variable "load_balancer_public_expose_https" {
  type        = bool
  default     = true
  description = "Set to true if the HTTPS port 443 should be exposed (for the public load balancer)"
}

variable "load_balancer_public_redirect_http_to_https" {
  type        = bool
  default     = true
  description = "Set to true if the HTTP port 80 should redirect to HTTPS (for the public load balancer)"
}

variable "load_balancer_public_additional_certs_arns" {
  type        = set(string)
  default     = []
  description = "A list of ARNs for public loadbalancer HTTPS listener additional certificates."
}

variable "load_balancer_private_expose_http" {
  type        = bool
  default     = true
  description = "Set to true if the HTTP port 80 should be exposed (for the private load balancer)"
}

variable "load_balancer_private_expose_https" {
  type        = bool
  default     = true
  description = "Set to true if the HTTPS port 443 should be exposed (for the private load balancer)"
}

variable "load_balancer_private_redirect_http_to_https" {
  type        = bool
  default     = true
  description = "Set to true if the HTTP port 80 should redirect to HTTPS (for the private load balancer)"
}

variable "load_balancer_private_additional_certs_arns" {
  type        = set(string)
  default     = []
  description = "A list of ARNs for private loadbalancer HTTPS listener additional certificates."
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

variable "load_balancer_private_whitelisted_prefix_lists" {
  type        = list(string)
  description = "A list of prefix list names to whitelist for restricted ip access to the private load balancer."
  default     = []
}

variable "load_balancer_public_restrict_ip_access" {
  type        = bool
  description = "Whether the public load balancer access should be restricted. It is useful to restrict access if a CDN is setup in front."
  default     = false
}

variable "load_balancer_public_restrict_token_access" {
  type        = bool
  default     = false
  description = "Set to true if the loadbalancer should refuse request without the correct x-auth-token"
}

variable "load_balancer_public_whitelisted_ips" {
  type        = list(string)
  description = "A list of IP ranges to whitelist for restricted ip access to the public load balancer."
  default     = []
}

variable "load_balancer_public_whitelisted_prefix_lists" {
  type        = list(string)
  description = "A list of prefix list names to whitelist for restricted ip access to the public load balancer."
  default     = []
}

variable "load_balancer_public_whitelisted_token_ips" {
  type        = list(string)
  description = "A list of IP ranges to whitelist for restricted token access to the public load balancer."
  default     = []
}

variable "load_balancer_public_token" {
  type        = string
  description = "The default header x_auth_token value set in alb rule to restrict access."
  default     = "x_auth_token_default_value"
  sensitive   = true
}

variable "load_balancer_autoscaling_groups" {
  type        = map(string)
  description = "A map associating a key to the name of the autoscaling groups containing the target instances, so that instances can be attached to the load balancer's target group. The keys must be known before apply."
}

variable "dns_hosted_zone_id" {
  type        = string
  description = "The ID of the hosted zone in Route53, under which the DNS record should be created. Can be null if no DNS records need to be created. Required if ssl_certificate_arn is null, to validate the certificate created by this module."
  default     = null
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

variable "ssl_certificate_arn" {
  type        = string
  description = "The ARN identifier of an existing Certificate in AWS Certificate Manager, to be used for HTTPS requests. If not defined, a new certificate will be issued and validated in the AWS Certificate Manager."
  default     = null
}

variable "ssl_certificate_domain_name" {
  type        = string
  description = "The complete domain name that will be written in the TLS certificate. Can include a wildcard. Not used if an existing certificate ARN is provided."
  default     = null
}

variable "public_tags" {
  type        = map(string)
  description = "The tags (a map of key/value pairs) to be applied to public loadbalancer resources."
  default     = {}
}

variable "private_tags" {
  type        = map(string)
  description = "The tags (a map of key/value pairs) to be applied to private loadbalancer resources."
  default     = {}
}

variable "tags" {
  type        = map(string)
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
  description = "The single port to use to health check all targets. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port."
  default     = "traffic-port"
}

variable "private_lb_health_check_ports" {
  type        = list(string)
  description = "The port list to use to health check all targets. If present, it should contain the same number of health check ports than the number of backends. If absent private_lb_health_check_port will be used."
  default     = []
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
  description = "The single port to use to health check all targets. Valid values are either ports 1-65535, or traffic-port. Defaults to traffic-port."
  default     = "traffic-port"
}

variable "public_lb_health_check_ports" {
  type        = list(string)
  description = "The port list to use to health check all targets. If present, it should contain the same number of health check ports than the number of backends. If absent private_lb_health_check_port will be used."
  default     = []
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

/* Public load balancer access logs params */
variable "public_lb_access_logs_enabled" {
  type        = bool
  description = "Wether to enable the public load balancer access logs or not."
  default     = false
}

variable "public_lb_access_logs_bucket_name" {
  type        = string
  description = "Override the public load balancer access logs bucket name."
  default     = ""
}

variable "public_lb_access_logs_bucket_prefix" {
  type        = string
  description = "The public load balancer access logs bucket prefix. Logs are stored in the root if not configured."
  default     = null
}

variable "public_lb_access_logs_expiration" {
  type        = number
  description = "Specifies the number of days for which public load balancer access logs are kept (indefinitely if not specified)."
  default     = null
}

variable "public_lb_access_logs_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the public load balancer access logs bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "public_lb_access_logs_bucket_encryption" {
  type        = bool
  description = "Should the public load balancer access logs bucket be encrypted using SSE-S3."
  default     = true
}

/* Private load balancer access logs params */
variable "private_lb_access_logs_enabled" {
  type        = bool
  description = "Wether to enable the private load balancer access logs or not."
  default     = false
}

variable "private_lb_access_logs_bucket_name" {
  type        = string
  description = "Override the private load balancer access logs bucket name."
  default     = ""
}

variable "private_lb_access_logs_bucket_prefix" {
  type        = string
  description = "The private load balancer access logs bucket prefix. Logs are stored in the root if not configured."
  default     = null
}

variable "private_lb_access_logs_expiration" {
  type        = number
  description = "Specifies the number of days for which private load balancer access logs are kept (indefinitely if not specified)."
  default     = null
}

variable "private_lb_access_logs_force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the private load balancer access logs bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "private_lb_access_logs_bucket_encryption" {
  type        = bool
  description = "Should the private load balancer access logs bucket be encrypted using SSE-S3."
  default     = true
}
