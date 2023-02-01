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

# We create an attachment for each combination of autoscaling_group and
# target_group in order to distribute evenly the load in the cluster.
#
# When working with unknown values in for_each, it's better to define the map keys statically in your
# configuration and place apply-time results only in the map values. Because of this, we use port count
# concatenated with autoscaling groups keys as for_each key, and we lookup target group ARNs and
# autoscaling groups names.

# Attach the autoscaling groups to the public ALB target groups
resource "aws_autoscaling_attachment" "quortex_public" {
  for_each = {
    for c in setproduct(
      range(length(var.load_balancer_public_app_backend_ports)),
      keys(var.load_balancer_autoscaling_groups)
    ) :
    "${var.load_balancer_public_app_backend_ports[c.0]}_${c.1}" => {
      // retrieve the target group ARN from the port count
      target_group_arn = aws_lb_target_group.quortex_public[c.0].arn
      // retrieve the autoscaling group name from its key
      autoscaling_group_name = var.load_balancer_autoscaling_groups[c.1]
    }
  }

  lb_target_group_arn    = each.value.target_group_arn
  autoscaling_group_name = each.value.autoscaling_group_name
}

# Attach the autoscaling groups to the private ALB target groups
resource "aws_autoscaling_attachment" "quortex_private" {
  for_each = {
    for c in setproduct(
      range(length(var.load_balancer_private_app_backend_ports)),
      keys(var.load_balancer_autoscaling_groups)
    ) :
    "${var.load_balancer_private_app_backend_ports[c.0]}_${c.1}" => {
      // retrieve the target group ARN from the port count
      target_group_arn = aws_lb_target_group.quortex_private[c.0].arn
      // retrieve the autoscaling group name from its key
      autoscaling_group_name = var.load_balancer_autoscaling_groups[c.1]
    }
  }

  lb_target_group_arn    = each.value.target_group_arn
  autoscaling_group_name = each.value.autoscaling_group_name
}
