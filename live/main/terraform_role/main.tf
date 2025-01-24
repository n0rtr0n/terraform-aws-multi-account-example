# Note that this state must be applied prior to any others, since it is the role that will be used to
# provision all other Terraform code. This should be applied using an admin-level role specific to
# the allowed_account_id
provider "aws" {
  # this will restrict which account can apply this, avoiding a mishap when authenticated to the wrong account
  allowed_account_ids = [
    local.aws_accounts.main.id,
  ]
  region = local.region
}

# the static shared configuration values
module "shared_config" {
  source = "../../../modules/shared_config"
}

# we pass these values to another module that configures the role that we can assume to apply Terraform
module "terraform_role" {
  source = "../../../modules/terraform_role"
  # note that this only gives access to one account to assume - the account id in which it is created
  account_ids_allowed_to_assume = [local.aws_accounts.main.id]
  region                        = local.region
  role_name                     = local.aws_accounts.main.terraform_role_name
}

locals {
  region       = "us-west-2"
  aws_accounts = module.shared_config.aws_accounts
}
