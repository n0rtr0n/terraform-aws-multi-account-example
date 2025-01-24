locals {
  account_ids_allowed_to_assume = var.account_ids_allowed_to_assume
  region                        = var.region
  role_name                     = var.role_name
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.account_ids_allowed_to_assume
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "admin" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
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
