# Multi Account Auth Example With Terraform

This repository demonstrates a working example of how a single management account can be used to provision resources in other AWS accounts. It is not intended to be a complete, production-ready example, just to show how various pieces can work together as a part of a multi-account strategy when using Terraform.


## Authentication

By deafult, the AWS Terraform provider will apply resources in the account ID of the provided credentials. So, for example, if authenticated to AccountA, AccountA's id will be used in the Terraform plan for resources that use the provider. If credentials are provided, the connected account of those credentials will be used instead. However, if an `assume_role` block is defined with a valid role that can be assumed by the current authenticated session, it will be used in the plan/apply, and the Terraform runner will inherit the permission level of that role.

```hcl
provider "aws" {
  assume_role {
    role_arn = "<arn that the Terraform applier can assume>"
  }
  allowed_account_ids = [
    "<aws account id of the role supplied above>"
  ]
  region = "<desired region>"
}
```

Note that in the example provider configuration above, `allowed_account_ids` also restrict the accounts to which these resources may be applied. This makes it much easier to prevent the accidental application of resources to an account where they should not exist by being explicit.

## Trust

This works because of the way that AWS allows you to establish trust between identities. In this example, a role is created, that provides access from principals in AccountB to assume this role in AccountA, although the resource is created in AccountA. In this way, a cross-account trust relationship is established, and when a principal in AccountB is given the privileges to do so, it may assume this role in AccountA to perform actions defined in its attached policies, which in this case is very unrestricted admin access (please do not actually use this in production):

```hcl
data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["<AccountA AWS id>", "<AccountB AWS id>"] # this line allows principals in either account to assume this role
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "AccountAAdminRole"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "admin" {
  statement {
    effect    = "Allow"
    actions   = ["*"] # beep boop beep boop!
    resources = ["*"] # danger zone!
  }
}

resource "aws_iam_policy" "admin" {
  name   = "Admin"
  policy = data.aws_iam_policy_document.admin.json
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.admin.arn
}
```

# Running this example

Because the role for Terraform needs to be created before it can be assumed, the order of operations here is very important. To follow along with this example, a few pre-requisites are in order:

* Two valid AWS accounts (we'll call them `AccountA` and `AccountB` respectively) that you control, and access to admin-level users in each of those
* Authenticated CLI sessions to both of these accounts
* Terraform (at the time of writing, v1.10, though anything v1.x+ should work)

Then:
1. Update the values in `modules/shared_config` to the actual ids of the accounts you control.
2. In the `live/main/terraform_role` directory, run a `terraform apply` using `AccountA`
3. In the `live/sandbox/terraform_role` directory, run a `terraform apply` using `AccountB`
4. In `live/main`, run `terraform plan` using `AccountA`. Apply is not necessary; just note as long as the plan succeeds, you should see an output that matches the role you created in step 2.
5. In `live/sandbox`, also run `terraform plan`, without applying, also using `AccountA`. Note that the output shows that the current account is the role you created in step 3, that is linked to `AccountB`, despite the fact that you are authenticated with `AccountA`