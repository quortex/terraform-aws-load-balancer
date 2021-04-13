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


# There are 2 options for specifying a TLS certificate for the Load Balancer: 
# - specify the ARN of an already existing and validated certificate
# - create the certificate ourselves in AWS Certificate Manager, and validate it.
# The resources below are used in the latter case. 

# Certificate in AWS Certificate Manager
resource "aws_acm_certificate" "cert" {
  count = var.ssl_certificate_arn == null ? 1 : 0

  domain_name       = var.ssl_certificate_domain_name
  validation_method = "DNS"

  tags = merge({
    Name = local.ssl_certificate_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Convert to a map, referenced by the certificate's ARN
  certs = { for c in aws_acm_certificate.cert : c.arn => c }
}

# DNS record to validate this certificate
resource "aws_route53_record" "cert_validation" {
  for_each = local.certs

  name    = tolist(each.value.domain_validation_options)[0].resource_record_name
  type    = tolist(each.value.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
  records = [tolist(each.value.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert" {
  for_each = local.certs

  certificate_arn         = each.value.arn
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}
