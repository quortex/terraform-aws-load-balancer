# Script to migrate terraform-aws-load-balancer state to v2
# https://github.com/quortex/terraform-aws-load-balancer/releases/tag/2.0.0
#
# This script handles replacing lb_target_group_arn by alb_target_group_arn
#
# To use it, you can do
# * Pull the old state with `terraform state pull > old.tfstate`
# * Convert it with `python3 convert_state_v2.py old.tfstate new.tfstate`
# * Push the new state with `terraform state push new.tfstate`

import argparse
import json

parser = argparse.ArgumentParser(
    description="Script to migrate terraform-aws-load-balancer state to v2."
)
parser.add_argument(
    "--load-balancer-module",
    help="The path of EKS module.",
    default="module.main.module.load-balancer",
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
        if all(resource[k] == v for k, v in kwargs.items())
    )


# Update aws_autoscaling_attachment of the module main.load-balancer
for resource in filter_resources(
    module=args.load_balancer_module,
    type="aws_autoscaling_attachment",
):
    for instance in resource["instances"]:
        # If alb_target_group_arn is set, move it to lb_target_group_arn
        if instance["attributes"]["alb_target_group_arn"]:
            instance["attributes"]["lb_target_group_arn"] = instance["attributes"][
                "alb_target_group_arn"
            ]
            instance["attributes"]["alb_target_group_arn"] = None

with open(args.output, "w") as f:
    json.dump(state, f, indent=2)
