module "tf_backend" {
  #providers            =  "aws"
  source               = "git::https://github.com/DNXLabs/terraform-aws-backend.git?ref=1.1.1"
  bucket_prefix        = "doug-github"
  bucket_sse_algorithm = "AES256"
  workspaces           = []
#   assume_policy = {
#     all = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root,${module.shared_services_infra_deploy.infra_deploy_role_arn}"
#   }
}

