# Note that this state must be applied prior to any others, since it is the role that will be used to
# provision all other Terraform code. This should be applied using an admin-level role specific to
# the allowed_account_id
provider "aws" {
  # this will restrict which account can apply this, avoiding a mishap when authenticated to the wrong account
  allowed_account_ids = [
    local.aws_accounts.sandbox.id,
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
  # we're doing something a little different here - notice that we pass the ability for the main
  # as well as the sandbox account to assume this role
  account_ids_allowed_to_assume = [
    local.aws_accounts.main.id,
    local.aws_accounts.sandbox.id,
  ]
  region    = local.region
  role_name = local.aws_accounts.sandbox.terraform_role_name
}

locals {
  region       = "us-west-2"
  aws_accounts = module.shared_config.aws_accounts
}
