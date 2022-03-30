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

output "public_lb_target_group_arns" {
  value       = aws_lb_target_group.quortex_public[*].arn
  description = "The ARN of the target groups that instances should be attached to. Once the load balancer and its target groups are created, instances that can listen must be attached to these groups."
}

output "public_lb_http_listener" {
  value       = try(aws_lb_listener.quortex_public_http.0.arn, null)
  description = "The HTTP listener arn of the public load balancer."
}

output "public_lb_tls_listener" {
  value       = try(aws_lb_listener.quortex_public_tls.0.arn, null)
  description = "The TLS listener arn of the public load balancer."
}

output "private_lb_target_group_arns" {
  value       = aws_lb_target_group.quortex_public[*].arn
  description = "The ARN of the target groups that instances should be attached to. Once the load balancer and its target groups are created, instances that can listen must be attached to these groups."
}

output "private_lb_http_listener" {
  value       = try(aws_lb_listener.quortex_private_http.0.arn, null)
  description = "The HTTP listener arn of the private load balancer."
}

output "private_lb_tls_listener" {
  value       = try(aws_lb_listener.quortex_private_tls.0.arn, null)
  description = "The TLS listener arn of the private load balancer."
}

output "dns_records_public" {
  value       = local.public_domains
  description = "A map with dns records in given dns zone for each dns_records_public provided in variables."
}

output "dns_records_private" {
  value       = local.private_domains
  description = "A map with dns records in given dns zone for each dns_records_private provided in variables."
}

output "dns_record_cdn" {
  value       = local.cdn_domain_name
  description = "The DNS record for the CDN"
}

output "cdn_distribution_id" {
  value       = length(aws_cloudfront_distribution.lb_distribution) != 0 ? aws_cloudfront_distribution.lb_distribution[0].id : null
  description = "The ID of the CloudFront distribution, if enabled"
}

output "lb_public_sg_id" {
  value       = aws_security_group.quortex_public.id
  description = "ID of the Security Group attached to the public load balancer."
}

output "ssl_certificate_cdn_arn" {
  value       = try(aws_acm_certificate.cert_cdn.0.arn, "")
  description = "ARN of the created CDN SSL certificate."
}

output "ssl_certificate_arn" {
  value       = try(aws_acm_certificate.cert.0.arn, "")
  description = "ARN of the created SSL certificate."
}
