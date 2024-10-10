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

# DNS record to validate this certificate
resource "aws_route53_record" "cert_validation" {
  count = var.ssl_certificate_arn == null ? 1 : 0

  name    = tolist(aws_acm_certificate.cert[0].domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.cert[0].domain_validation_options).0.resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
  records = [tolist(aws_acm_certificate.cert[0].domain_validation_options).0.resource_record_value]
  ttl     = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert" {
  count = var.ssl_certificate_arn == null ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
}

# Additional Public Certificate in AWS Certificate Manager
resource "aws_acm_certificate" "additional_cert_public" {
  count = length(var.load_balancer_public_additional_certs_hostnames) > 0 ? 1 : 0

  domain_name               = tolist(var.load_balancer_public_additional_certs_hostnames)[0]
  subject_alternative_names = tolist(var.load_balancer_public_additional_certs_hostnames)
  validation_method         = "DNS"

  tags = merge({
    Name = "${local.ssl_certificate_name}-additional-public"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record to validate this certificate
resource "aws_route53_record" "additional_cert_public_validation" {
  count = length(var.load_balancer_public_additional_certs_hostnames) > 0 ? 1 : 0

  name    = tolist(aws_acm_certificate.additional_cert_public[0].domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.additional_cert_public[0].domain_validation_options).0.resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
  records = [tolist(aws_acm_certificate.additional_cert_public[0].domain_validation_options).0.resource_record_value]
  ttl     = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "additional_cert_public" {
  count = length(var.load_balancer_public_additional_certs_hostnames) > 0 ? 1 : 0

  certificate_arn         = aws_acm_certificate.additional_cert_public[0].arn
  validation_record_fqdns = [aws_route53_record.additional_cert_public_validation[0].fqdn]
}

# Additional Private Certificate in AWS Certificate Manager
resource "aws_acm_certificate" "additional_cert_private" {
  count = length(var.load_balancer_private_additional_certs_hostnames) > 0 ? 1 : 0

  domain_name               = tolist(var.load_balancer_private_additional_certs_hostnames)[0]
  subject_alternative_names = tolist(var.load_balancer_private_additional_certs_hostnames)
  validation_method         = "DNS"

  tags = merge({
    Name = "${local.ssl_certificate_name}-additional-private"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record to validate this certificate
resource "aws_route53_record" "additional_cert_private_validation" {
  count = length(var.load_balancer_private_additional_certs_hostnames) > 0 ? 1 : 0

  name    = tolist(aws_acm_certificate.additional_cert_private[0].domain_validation_options).0.resource_record_name
  type    = tolist(aws_acm_certificate.additional_cert_private[0].domain_validation_options).0.resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
  records = [tolist(aws_acm_certificate.additional_cert_private[0].domain_validation_options).0.resource_record_value]
  ttl     = 60
}

# Certificate validation
resource "aws_acm_certificate_validation" "additional_cert_private" {
  count = length(var.load_balancer_private_additional_certs_hostnames) > 0 ? 1 : 0

  certificate_arn         = aws_acm_certificate.additional_cert_private[0].arn
  validation_record_fqdns = [aws_route53_record.additional_cert_private_validation[0].fqdn]
}
