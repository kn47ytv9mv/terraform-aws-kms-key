resource "aws_kms_key" "resource" {
  description = var.description

  enable_key_rotation     = var.enable_key_rotation
  rotation_period_in_days = var.rotation_period_in_days
  is_enabled              = var.is_enabled

  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region

  deletion_window_in_days = var.deletion_window_in_days
  policy                  = var.policy

  tags = var.tags
}

output "id" {
  description = "The key's ID, the short identifier distinct from its ARN. Either form works as terraform-aws-kms-alias's target_key_id."
  value       = aws_kms_key.resource.key_id
}

output "arn" {
  description = "The ARN of the key."
  value       = aws_kms_key.resource.arn
}

output "region" {
  description = "The region the key was created in."
  value       = aws_kms_key.resource.region
}
