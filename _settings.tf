# terraform {
#   backend "s3" {
#     bucket         = "tutis-terraform-backend"
#     key            = "openvpn"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-lock"
#     role_arn       = "arn:aws:iam::158947203889:role/terraform-backend"
#   }
# }

provider "aws" {
  region  = "ap-southeast-2"
  version = "3.3.0"

  # assume_role {
  #   role_arn = "arn:aws:iam::${local.workspace["aws-account-id"]}:role/${local.workspace["aws-role"]}"
  # }
}

locals {
  env       = yamldecode(file("${path.module}/one.yaml"))
  workspace = local.env["workspaces"][terraform.workspace]
}
