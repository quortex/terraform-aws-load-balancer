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


# Certificate to use with CloudFront CDN
#
# This certificate will be attached to the CDN distribution, to verify that we have the rights to use
# the alternate domain names specified in the CDN distribution.
resource "aws_acm_certificate" "cert_cdn" {
  count = (var.cdn_create_distribution && var.cdn_ssl_certificate_arn == null && var.cdn_dns_record != null) ? 1 : 0

  provider          = aws.us-east-1 # the certificate used in CloudFront CDN has to be located in th "us-east-1" (N. Virginia) region
  domain_name       = local.cdn_domain_name
  validation_method = "DNS"

  tags = merge(
    { Name = local.cdn_domain_name },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record to validate this certificate
resource "aws_route53_record" "cert_validation_cdn" {
  count = (var.cdn_create_distribution && var.cdn_ssl_certificate_arn == null && var.cdn_dns_record != null) ? 1 : 0

  provider = aws.dns # the certificate used in CloudFront CDN has to be located in th "us-east-1" (N. Virginia) region
  name     = tolist(aws_acm_certificate.cert_cdn[0].domain_validation_options).0.resource_record_name
  type     = tolist(aws_acm_certificate.cert_cdn[0].domain_validation_options).0.resource_record_type
  zone_id  = data.aws_route53_zone.selected[0].zone_id
  records  = [tolist(aws_acm_certificate.cert_cdn[0].domain_validation_options).0.resource_record_value]
  ttl      = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert_cdn" {
  count = (var.cdn_create_distribution && var.cdn_ssl_certificate_arn == null) ? 1 : 0

  provider                = aws.us-east-1 # the certificate used in CloudFront CDN has to be located in th "us-east-1" (N. Virginia) region
  certificate_arn         = aws_acm_certificate.cert_cdn[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation_cdn[0].fqdn]
}
