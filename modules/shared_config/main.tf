locals {
  aws_accounts = {
    // these account numbers are totally made up, just here for the sake of example
    // also, the terraform role will need to be create via the "terraform_role" state within each account directory
    // the format will be here eventually, but this denormalization is to prevent the need for a state lookup
    // when declaring AWS provider configuration with one of these roles, which may not work at all
    main = {
      id                  = 123456789012
      terraform_role_name = "MainAdmin"
      terraform_role_arn  = "arn:aws:iam::$123456789012:role/MainAdmin"
    }
    sandbox = {
      id                  = 098765432109
      terraform_role_name = "SandboxAdmin"
      terraform_role_arn  = "arn:aws:iam::098765432109:role/SandboxAdmin"
    }
  }
}
