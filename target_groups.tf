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

# Attach the autoscaling groups to the public ALB target groups 
resource "aws_autoscaling_attachment" "quortex_public" {
  # No target group will be created (yet) if backend port is not defined
  count = length(var.load_balancer_public_app_backend_ports) > 0 ? length(var.load_balancer_autoscaling_group_names) : 0
  
  autoscaling_group_name = var.load_balancer_autoscaling_group_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.quortex_public[0].arn
}

# Attach the autoscaling groups to the private ALB target groups
resource "aws_autoscaling_attachment" "quortex_private" {
  # No target group will be created (yet) if backend port is not defined
  count = length(var.load_balancer_private_app_backend_ports) > 0 ? length(var.load_balancer_autoscaling_group_names) : 0
  
  autoscaling_group_name = var.load_balancer_autoscaling_group_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.quortex_private[0].arn
}

