[![Quortex][logo]](https://quortex.io)

# terraform-aws-load-balancer

A terraform module for Quortex infrastructure AWS load balancing layer.

It provides a set of resources necessary to provision the load balancing and DNS configuration of the Quortex infrastructure on Amazon AWS, via EKS.

![infra_diagram]

This module is available on [Terraform Registry][registry_tf_aws-eks_load_balancer].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources in AWS:

For external services (live stream):
- an ALB, with listeners for HTTP (80) and HTTPS (443)
- a security group for this ALB, open to 0.0.0.0/0 on 80 and 443
- a target group, which port should be set to the Kubernetes service NodePort (can be empty during a first pass, and defined after the services are deployed inside the cluster)
- DNS record aliases (api.<cluster_name>) for the ALB (created under an existing hosted zone)

For internal services with restricted access (api, grafana, weave…):
- an ALB, with listeners for HTTP (80) and HTTPS (443)
- a security group restricted to specified IPs on 80 and 443
- a target group, which port should be set to the Kubernetes service NodePort (can be empty during a first pass, and defined after the services are deployed inside the cluster)
- DNS record aliases (api.<cluster_name>, grafana.<cluster_name>...) for the ALB (created under an existing hosted zone)

The load balancers should be in the public subnets.

The following resources are also created, and are common to external and internal services:
- rules are added to the cluster’s security group to allow the ALB to join the services’ NodePorts.
- (optional) a TLS certificate, in AWS Certificate Manager, with the domain name “*.<cluster_name>.<hosted_zone>”

The TLS certificate can be created by this module (it will be issued and validated in AWS Certificate Manager), or a certificate already existing in ACM can be specified.

## Usage example

```

module "load-balancer" {
  source = "quortex/load-balancer/aws"
  
  name                                    = "quortexcluster"

  # values from the Quortex network module:
  vpc_id                                  = module.network.vpc_id
  subnet_ids                              = module.network.public_subnet_ids
  access_cidr_blocks                      = module.network.vpc_cidr_block

  # values from the Quortex cluster module:
  cluster_security_group_id               = module.eks.cluster_security_group_id
  load_balancer_autoscaling_group_names   = module.eks.autoscaling_group_names

  # Load balancers backend configuration.
  load_balancer_public_app_backend_ports  = [var.service_nodeport_public]
  load_balancer_private_app_backend_ports = [var.service_nodeport_private]

  # SSL configuration.
  ssl_certificate_domain_name             = "*.mydomain.com"
    
  # DNS configuration.
  dns_hosted_zone_id                      = var.hosted_zone_id
  dns_records_public                      = { 
                                                live = "live.domain" 
                                            }
  dns_records_private                     = {
                                                api     = "api.domain"
                                                grafana = "grafana.domain"
                                                weave   = "weave.domain"
                                            }

  # A list of IP ranges to whitelist for private load balancer access.
  load_balancer_private_whitelisted_ips   = ["98.235.24.130/32"]
}

```

## Upgrading

When upgrading an existing infrastructure from 1.6.0 to 1.7.0, the script migrate_terraform_security_group_rules.sh should be used to seamlessly migrate from inline security group rules to separate rule resources.

> **Warning**
> Upgrade from 4.0.0 to 5.0.0 is a breaking change. Replacement of aws_security_group_rule resources by aws_vpc_security_group_ingress_rule & aws_vpc_security_group_egress_rule can create conflicts and rules will be overwritten.

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for AWS.

Check out these related projects.

- [terraform-aws-network][registry_tf_aws-eks_network] - A terraform module for Quortex infrastructure network layer.

- [terraform-aws-eks-cluster][registry_tf_aws-eks_cluster] - A terraform module for Quortex infrastructure AWS cluster layer.

- [terraform-aws-storage][registry_tf_aws-eks_storage] - A terraform module for Quortex infrastructure AWS persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-aws-load-balancer/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [infra_diagram]: https://storage.googleapis.com/quortex-assets/infra_aws_002.jpg

  [email]: mailto:info@quortex.io

  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_aws-eks_network]: https://registry.terraform.io/modules/quortex/network/aws
  [registry_tf_aws-eks_cluster]: https://registry.terraform.io/modules/quortex/eks-cluster/aws
  [registry_tf_aws-eks_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/aws
  [registry_tf_aws-eks_storage]: https://registry.terraform.io/modules/quortex/storage/aws
  [github_tf_modules]: https://github.com/quortex?q=terraform-
