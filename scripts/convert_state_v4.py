# Script to migrate terraform-aws-load-balancer state to v4
# https://github.com/quortex/terraform-aws-load-balancer/releases/tag/4.0.0
#
# This script handles reindexing lb_target_group_arn by <target_group_port>_<autoscaling_group_key>
#
# To use it, you can do
# * Pull the old state with `terraform state pull > old.tfstate`
# * Convert it with `python3 convert_state_v4.py old.tfstate new.tfstate`
# * Push the new state with `terraform state push new.tfstate`

import argparse
import json
from typing import Any, Generator

parser = argparse.ArgumentParser(
    description="Script to migrate terraform-aws-load-balancer state to v4."
)
parser.add_argument(
    "--load-balancer-module",
    help="The path of EKS module.",
    default="module.main.module.load-balancer",
)
parser.add_argument(
    "--eks-module",
    help="The path of EKS module.",
    default="module.main.module.eks",
)
parser.add_argument("input", help="The state file to use.")
parser.add_argument("output", help="The state file to output.")
args = parser.parse_args()

state = dict()
with open(args.input, "r") as f:
    state = json.load(f)

# Increment serial
state["serial"] += 1


def filter_resources(**kwargs):
    return (
        resource
        for resource in state["resources"]
        if all(resource.get(k) == v for k, v in kwargs.items())
    )


# Find a aws_lb_target_group matching the provided arn and return its port
def find_tg_port(arn: str) -> str:
    for resource in filter_resources(
        module=args.load_balancer_module,
        type="aws_lb_target_group",
    ):
        for instance in resource["instances"]:
            if instance["attributes"]["id"] == arn:
                return instance["attributes"]["port"]

    return ""


# Find a aws_lb_target_group matching the provided arn and return its port
def find_asg_key(name: str) -> str:
    # Search name in eks node groups
    for resource in filter_resources(
        module=args.eks_module,
        type="aws_eks_node_group",
    ):
        for instance in resource["instances"]:
            for resource2 in instance["attributes"]["resources"]:
                for asg in resource2["autoscaling_groups"]:
                    if asg["name"] == name:
                        return f'eks-managed-{instance["index_key"]}'

    # Search name in self-managed ASGs
    for resource in filter_resources(
        module=args.eks_module,
        type="aws_autoscaling_group",
    ):
        for instance in resource["instances"]:
            if instance["attributes"]["id"] == name:
                return f'self-managed-{instance["index_key"]}'

    return ""


# Update aws_autoscaling_attachment of the module main.load-balancer
for resource in filter_resources(
    module=args.load_balancer_module,
    type="aws_autoscaling_attachment",
):
    for instance in resource["instances"]:
        # Find the port using the lb_target_group_arn
        target_group_port = find_tg_port(instance["attributes"]["lb_target_group_arn"])
        autoscaling_group_key = find_asg_key(
            instance["attributes"]["autoscaling_group_name"]
        )

        # Modify index to <target_group_port>_<autoscaling_group_key>
        if target_group_port and autoscaling_group_key:
            instance["index_key"] = f"{target_group_port}_{autoscaling_group_key}"
        else:
            print(
                f"Failed to find target_group_port or autoscaling_group_key for aws_autoscaling_attachment : {instance}"
            )

with open(args.output, "w") as f:
    json.dump(state, f, indent=2)
