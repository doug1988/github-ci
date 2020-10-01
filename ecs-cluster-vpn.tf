resource "aws_security_group" "openvpn" {
  name   = "openvpn-${local.workspace["account_name"]}"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "openvpn" {
  name        = "openvpn-${local.workspace["account_name"]}"
  path        = "/"
  description = "Policy for OpenVPN EC2 instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "ec2:DescribeAddresses"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_route53_record" "openvpn" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.workspace["domain_name"]
  type    = "A"
  ttl     = "300"
  records = [aws_eip.openvpn.public_ip]
}

resource "aws_eip" "openvpn" {
  vpc = true
}

module "ecs_vpn" {
  source = "git::https://github.com/DNXLabs/terraform-aws-ecs.git?ref=3.1.2"

  name                 = local.workspace["cluster_name"]
  instance_type_1      = "t3.micro"
  instance_type_2      = "t2.micro"
  instance_type_3      = "t3.small"
  alb                  = false
  asg_min              = 1
  asg_max              = 1
  vpc_id               = data.aws_vpc.selected.id
  private_subnet_ids   = data.aws_subnet_ids.private.ids
  public_subnet_ids    = data.aws_subnet_ids.public.ids
  secure_subnet_ids    = data.aws_subnet_ids.secure.ids
  on_demand_percentage = 0
  certificate_arn      = ""
  security_group_ids   = [aws_security_group.openvpn.id]

  userdata = <<EOT
INSTANCE_ID=`curl -w '\n' -s http://169.254.169.254/latest/meta-data/instance-id`

ALLOCATION_ID=`aws --region ${data.aws_region.current.name} ec2 describe-addresses --allocation-ids ${aws_eip.openvpn.id} --query 'Addresses[0].AssociationId' --output text`
aws --region ${data.aws_region.current.name} ec2 disassociate-address --allocation-id $${ALLOCATION_ID} || true
sleep 5
aws --region ${data.aws_region.current.name} ec2 associate-address --allocation-id ${aws_eip.openvpn.id} --instance-id $${INSTANCE_ID}
EOT
}

resource "aws_iam_role_policy_attachment" "ecs_extra" {
  role       = module.ecs_vpn.ecs_iam_role_name
  policy_arn = aws_iam_policy.openvpn.arn
}
