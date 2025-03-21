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


data "aws_route53_zone" "selected" {
  count = var.dns_hosted_zone_id == null ? 0 : 1

  zone_id = var.dns_hosted_zone_id
}

# Locals block for DNS management.
locals {
  public_domains  = { for k, v in aws_route53_record.quortex_public : k => v.fqdn }
  private_domains = { for k, v in aws_route53_record.quortex_private : k => v.fqdn }
  all_domains     = concat(values(local.private_domains), values(local.public_domains))
}

# DNS record aliases that target the load balancer
resource "aws_route53_record" "quortex_public" {
  for_each = length(var.load_balancer_public_app_backend_ports) > 0 ? var.dns_records_public : {}

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_lb.quortex_public[0].dns_name
    zone_id                = aws_lb.quortex_public[0].zone_id
    evaluate_target_health = false
  }
}

# Additional DNS record aliases that target the public load balancer
resource "aws_route53_record" "quortex_public_additional" {
  for_each = length(var.load_balancer_public_app_backend_ports) > 0 ? var.load_balancer_public_additional_dns_records : []

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_lb.quortex_public[0].dns_name
    zone_id                = aws_lb.quortex_public[0].zone_id
    evaluate_target_health = false
  }
}

# DNS record aliases that target the load balancer
resource "aws_route53_record" "quortex_private" {
  for_each = var.dns_records_private

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_lb.quortex_private[0].dns_name
    zone_id                = aws_lb.quortex_private[0].zone_id
    evaluate_target_health = false
  }
}

# Additional DNS record aliases that target the private load balancer
resource "aws_route53_record" "quortex_private_additional" {
  for_each = length(var.load_balancer_private_app_backend_ports) > 0 ? var.load_balancer_private_additional_dns_records : []

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_lb.quortex_private[0].dns_name
    zone_id                = aws_lb.quortex_private[0].zone_id
    evaluate_target_health = false
  }
}
