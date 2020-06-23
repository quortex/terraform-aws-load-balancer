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


resource "aws_security_group_rule" "quortex_ingress_public" {
  count = length(var.load_balancer_public_app_backend_ports)

  description       = "Allow access to the public ingress service (nodeport ${var.load_balancer_public_app_backend_ports[count.index]}) from the Load Balancer"
  security_group_id = var.cluster_security_group_id

  protocol  = "tcp"
  type      = "ingress"
  from_port = var.load_balancer_public_app_backend_ports[count.index]
  to_port   = var.load_balancer_public_app_backend_ports[count.index]

  cidr_blocks = var.access_cidr_blocks
}

resource "aws_security_group_rule" "quortex_ingress_private" {
  count = length(var.load_balancer_private_app_backend_ports)

  description       = "Allow access to the private ingress service (nodeport ${var.load_balancer_private_app_backend_ports[count.index]}) from the Load Balancer"
  security_group_id = var.cluster_security_group_id


  protocol  = "tcp"
  type      = "ingress"
  from_port = var.load_balancer_private_app_backend_ports[count.index]
  to_port   = var.load_balancer_private_app_backend_ports[count.index]

  cidr_blocks = var.access_cidr_blocks
}