output "terraform_role_arn" {
  description = "The ARN of the Terraform role"
  value       = module.terraform_role.arn
}
