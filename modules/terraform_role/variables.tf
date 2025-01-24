variable "account_ids_allowed_to_assume" {
  description = "A list of AWS account ids that can assume this Terraform role"
  type        = list(any)
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "role_name" {
  description = "Name of the Terraform role"
}
