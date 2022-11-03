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

// This file is made to add health check nodeports to security groups if they are not "traffic-port"

// Filter ports that are not "traffic-port" from public_lb_health_check_ports list,
// or if empty make a list from public_lb_health_check_port if its not "traffic-port"
locals {
  public_specific_hc_ports = toset(length(var.public_lb_health_check_ports) > 0 ? [
    for port in var.public_lb_health_check_ports : port if port != "traffic-port"
  ] : (var.public_lb_health_check_port != "traffic-port" ? [var.public_lb_health_check_port] : []))
  private_specific_hc_ports = toset(length(var.private_lb_health_check_ports) > 0 ? [
    for port in var.private_lb_health_check_ports : port if port != "traffic-port"
  ] : (var.private_lb_health_check_port != "traffic-port" ? [var.private_lb_health_check_port] : []))
}

resource "aws_security_group_rule" "quortex_ingress_public_health" {
  for_each = local.public_specific_hc_ports

  description       = "Allow access to the public ingress health check (nodeport ${each.value}) from the Load Balancer"
  security_group_id = var.cluster_security_group_id

  protocol  = "tcp"
  type      = "ingress"
  from_port = tonumber(each.value)
  to_port   = tonumber(each.value)

  cidr_blocks = var.access_cidr_blocks
}

resource "aws_security_group_rule" "quortex_ingress_private_health" {
  for_each = local.private_specific_hc_ports

  description       = "Allow access to the private ingress health check (nodeport ${each.value}) from the Load Balancer"
  security_group_id = var.cluster_security_group_id

  protocol  = "tcp"
  type      = "ingress"
  from_port = tonumber(each.value)
  to_port   = tonumber(each.value)

  cidr_blocks = var.access_cidr_blocks
}
