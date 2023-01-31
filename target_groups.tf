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

# Attach each autoscaling group to each target group
# The setproduct is maybe a bit overkill since there should be only 0 or 1 target group...

locals {
  # We create an attachment for each autoscaling_group / target_group
  # combination in order to best distribute the load in the cluster.
  quortex_public_attachments = {
    for c in setproduct(aws_lb_target_group.quortex_public.*.arn, var.load_balancer_autoscaling_group_names) :
    "${c.0}_${c.1}" => { "target_group_arn" : c.0, "asg_name" : c.1 }
  }
  quortex_private_attachments = {
    for c in setproduct(aws_lb_target_group.quortex_private.*.arn, var.load_balancer_autoscaling_group_names) :
    "${c.0}_${c.1}" => { "target_group_arn" : c.0, "asg_name" : c.1 }
  }
}

# Attach the autoscaling groups to the public ALB target groups
resource "aws_autoscaling_attachment" "quortex_public" {
  # No target group will be created if backend port is not defined
  for_each = length(var.load_balancer_public_app_backend_ports) > 0 ? local.quortex_public_attachments : {}

  autoscaling_group_name = each.value.asg_name
  lb_target_group_arn   = each.value.target_group_arn
}

# Attach the autoscaling groups to the private ALB target groups
resource "aws_autoscaling_attachment" "quortex_private" {
  # No target group will be created if backend port is not defined
  for_each = length(var.load_balancer_private_app_backend_ports) > 0 ? local.quortex_private_attachments : {}

  autoscaling_group_name = each.value.asg_name
  lb_target_group_arn   = each.value.target_group_arn
}
