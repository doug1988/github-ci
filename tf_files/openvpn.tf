# module "openvpn" {
#   source = "git::https://github.com/DNXLabs/terraform-aws-openvpn.git?ref=0.6.0"

#   vpc_id          = data.aws_vpc.selected.id
#   requester_cidrs = data.aws_subnet.private.*.cidr_block
#   cluster_name    = module.ecs_vpn.ecs_name
#   task_role_arn   = module.ecs_vpn.ecs_task_iam_role_arn
#   name            = local.workspace["account_name"]
#   domain_name     = local.workspace["domain_name"]
#   route_push      = local.workspace["route_push"]
#   mfa             = true
# }
