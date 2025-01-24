provider "aws" {
  # this requires the terraform_role state to be applied. although we could grab the ARN from the
  # output of that state, the identifier should be stable enough, and this prevents a state lookup prior
  # to the provider declaration
  assume_role {
    role_arn = local.aws_accounts.main.terraform_role_arn
  }
  # this ensures that we will not accidentally apply Terraform to the wrong account
  allowed_account_ids = [
    local.aws_accounts.main.id,
  ]
  region = local.region
}

module "shared_config" {
  source = "../../modules/shared_config"
}

locals {
  region       = "us-west-2"
  aws_accounts = module.shared_config.aws_accounts
}

resource "random_string" "this" {
  length  = 24
  special = false
}
# create a bucket with a completely random name, to make sure this test plan passes
resource "aws_s3_bucket" "this" {
  bucket = random_string.this.result
  tags = {
    environment = "main"
  }
}

# this should output the ARN of the role we assume in the provider definition
output "current_role" {
  value = data.aws_caller_identity.this.arn
}
