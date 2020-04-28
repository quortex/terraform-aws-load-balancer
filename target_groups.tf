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

# Attach the autoscaling groups to the public ALB target groups (there should be 0 or 1 target group)
resource "aws_autoscaling_attachment" "quortex_public" {
  count = length(var.load_balancer_autoscaling_group_names) * length(aws_lb_target_group.quortex_public)

  autoscaling_group_name = var.load_balancer_autoscaling_group_names[count.index / length(var.load_balancer_autoscaling_group_names)]
  alb_target_group_arn   = aws_lb_target_group.quortex_public[count.index % length(var.load_balancer_autoscaling_group_names)].arn

  # note: the use of / and % is to fake a nested for_each loop
}

# Attach the autoscaling groups to the private ALB target groups (there should be 0 or 1 target group)
resource "aws_autoscaling_attachment" "quortex_private" {
  count = length(var.load_balancer_autoscaling_group_names) * length(aws_lb_target_group.quortex_public)

  autoscaling_group_name = var.load_balancer_autoscaling_group_names[count.index / length(var.load_balancer_autoscaling_group_names)]
  alb_target_group_arn   = aws_lb_target_group.quortex_private[count.index % length(var.load_balancer_autoscaling_group_names)].arn

  # note: the use of / and % is to fake a nested for_each loop
}