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
  private_lb_security_group_name = length(var.private_lb_security_group_name) > 0 ? var.private_lb_security_group_name : "${var.resource_name}-priv"
  private_lb_name                = length(var.private_lb_name) > 0 ? var.private_lb_name : "${var.resource_name}-priv"
  private_lb_target_group_name   = length(var.private_lb_target_group_name) > 0 ? var.private_lb_target_group_name : "${var.resource_name}-priv"
  public_lb_security_group_name  = length(var.public_lb_security_group_name) > 0 ? var.public_lb_security_group_name : "${var.resource_name}-pub"
  public_lb_name                 = length(var.public_lb_name) > 0 ? var.public_lb_name : "${var.resource_name}-pub"
  public_lb_target_group_name    = length(var.public_lb_target_group_name) > 0 ? var.public_lb_target_group_name : "${var.resource_name}-pub"
  ssl_certificate_name           = length(var.ssl_certificate_name) > 0 ? var.ssl_certificate_name : var.resource_name
  cdn_distribution_name          = length(var.cdn_distribution_name) > 0 ? var.cdn_distribution_name : var.resource_name
  cdn_ssl_certificate_name       = length(var.cdn_ssl_certificate_name) > 0 ? var.cdn_ssl_certificate_name : "${var.resource_name}-cdn"
}
