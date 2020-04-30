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

variable "name" {
  type        = string
  description = "This value will be in the Name tag of all resources."
}

variable "region" {
  type        = string
  description = "The region in wich to create load balancers."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which the ALB should be."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets (worker node subnets)"
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks of the subnets"
}

variable "cluster_security_group_id" {
  type        = string
  description = "ID of the cluster security group created by EKS. Rules will be added to it, to allow traffic to the backend nodeports (restricted to the subnet cidr)."
}

variable "load_balancer_public_app_backend_ports" {
  type        = list(number)
  description = "The port number on which backend instances are listening"
}

variable "load_balancer_private_app_backend_ports" {
  type        = list(number)
  description = "The port number on which backend instances are listening"
}

variable "load_balancer_private_whitelisted_ips" {
  type        = list(string)
  description = "A list of IP ranges to whitelist for private access."
  default     = []
}

variable "load_balancer_autoscaling_group_names" {
  type        = list(string)
  description = "The name of the autoscaling groups containing the target instances, so that instances can be attached to the load balancer's target group."
}

variable "dns_hosted_zone_id" {
  type        = string
  description = "The ID of the hosted zone in Route53, under which the DNS record should be created."
}

variable "dns_records_private" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for private endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "dns_records_public" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for public endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "ssl_certificate_subdomain" {
  type        = string
  description = "The subdomain name that will be written in the TLS certificate. Can include a wildcard. The hosted zone name will be appended to form the complete domain name."
}

variable "tags" {
  type        = map
  description = "The tags (a map of key/value pairs) to be applied to created resources."
  default     = {}
}
