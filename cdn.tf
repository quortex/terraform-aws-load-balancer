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


locals {
  cdn_domain_name = var.cdn_dns_record != null ? "${var.cdn_dns_record}.${trimsuffix(data.aws_route53_zone.selected[0].name, ".")}" : null
  origin_domain_name = var.cdn_origin != null ? "${var.dns_records_public[var.cdn_origin]}.${trimsuffix(data.aws_route53_zone.selected[0].name, ".")}" : aws_lb.quortex_public.dns_name
}

resource "aws_cloudfront_distribution" "lb_distribution" {
  count = var.cdn_create_distribution ? 1 : 0

  aliases = var.cdn_dns_record != null ? [local.cdn_domain_name] : [] # Add the DNS record as an additional CNAME

  enabled         = var.cdn_enabled
  http_version    = var.cdn_http_version
  is_ipv6_enabled = var.cdn_ipv6_enabled
  price_class     = var.cdn_price_class

  origin {
    origin_id   = "main"
    domain_name = local.origin_domain_name
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  default_cache_behavior {
    target_origin_id = "main"

    allowed_methods        = var.cdn_allowed_methods
    cached_methods         = var.cdn_cached_methods
    compress               = var.cdn_compress
    default_ttl            = var.cdn_default_ttl
    max_ttl                = var.cdn_max_ttl
    min_ttl                = var.cdn_min_ttl
    smooth_streaming       = var.cdn_smooth_streaming
    viewer_protocol_policy = var.cdn_viewer_protocol_policy

    forwarded_values {
      headers                 = var.cdn_forwarded_headers
      query_string            = var.cdn_forward_query_string
      query_string_cache_keys = var.cdn_query_string_cache_keys

      cookies {
        forward           = var.cdn_cookies_forward
        whitelisted_names = var.cdn_cookies_whitelisted_names
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cdn_ordered_cache_behaviors
    iterator = behavior
    content {
      target_origin_id = "main"

      path_pattern           = behavior.value["path_pattern"]
      allowed_methods        = behavior.value["allowed_methods"]
      cached_methods         = behavior.value["cached_methods"]
      compress               = behavior.value["compress"]
      default_ttl            = behavior.value["default_ttl"]
      max_ttl                = behavior.value["max_ttl"]
      min_ttl                = behavior.value["min_ttl"]
      smooth_streaming       = behavior.value["smooth_streaming"]
      viewer_protocol_policy = behavior.value["viewer_protocol_policy"]

      forwarded_values {
        headers                 = behavior.value["forwarded_headers"]
        query_string            = behavior.value["forward_query_string"]
        query_string_cache_keys = behavior.value["query_string_cache_keys"]

        cookies {
          forward           = behavior.value["cookies_forward"]
          whitelisted_names = behavior.value["cookies_whitelisted_names"]
        }
      }
    }
  }

  # TLS configuration
  viewer_certificate {
    acm_certificate_arn            = var.cdn_ssl_certificate_arn != null ? var.cdn_ssl_certificate_arn : values(aws_acm_certificate_validation.cert_cdn)[0].certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }

  # Geographical restriction
  restrictions {
    geo_restriction {
      locations        = var.cdn_geo_restriction_locations
      restriction_type = var.cdn_geo_restriction_type
    }
  }

  # tags
  tags = merge({
    Name = local.cdn_distribution_name
    },
    var.tags
  )

  # terraform resource behavior
  retain_on_delete    = false
  wait_for_deployment = var.cdn_wait_for_deployment
}

# DNS record that targets the CDN distribution (optional)
resource "aws_route53_record" "quortex_cdn" {
  count = (var.cdn_create_distribution && var.cdn_dns_record != null) ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.cdn_dns_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.lb_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.lb_distribution[0].hosted_zone_id
    evaluate_target_health = false
  }
}
