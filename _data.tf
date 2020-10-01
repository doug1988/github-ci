data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${local.workspace["account_name"]}-VPC"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Scheme"
    values = ["public"]
  }
}

# data "aws_subnet_ids" "transit" {
#   vpc_id = data.aws_vpc.selected.id

#   filter {
#     name   = "tag:Scheme"
#     values = ["transit"]
#   }
# }

# data "aws_subnet" "transit" {
#   count = length(data.aws_subnet_ids.transit.ids)
#   id    = tolist(data.aws_subnet_ids.transit.ids)[count.index]
# }

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Scheme"
    values = ["private"]
  }
}

data "aws_subnet" "private" {
  count = length(data.aws_subnet_ids.private.ids)
  id    = tolist(data.aws_subnet_ids.private.ids)[count.index]
}


data "aws_subnet_ids" "secure" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Scheme"
    values = ["secure"]
  }
}

data "aws_route53_zone" "selected" {
  name = local.workspace["hosted_zone"]
}

data "aws_region" "current" {}
