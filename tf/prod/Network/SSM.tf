//イメージアップロード用
resource "aws_ssm_parameter" "ecr_registry_url" {
  name        = "/backend/ecr_registry_url"
  value       = split("/", aws_ecr_repository.repository.repository_url)[0]
  type        = "String"
  description = "URL of ECR registry"
}
resource "aws_ssm_parameter" "ecr_repository_url" {
  name        = "/backend/ecr_repository_url"
  value       = aws_ecr_repository.repository.repository_url
  type        = "String"
  description = "URL of ECR repository"
}
resource "aws_ssm_parameter" "db_user" {
  name        = "/db/db_user"
  value       = "replace me"
  type        = "SecureString"
  description = "db user"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "db_password" {
  name        = "/db/db_password"
  value       = "replace me"
  type        = "SecureString"
  description = "db password"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "db_database" {
  name        = "/db/db_database"
  value       = "replace me"
  type        = "SecureString"
  description = "db database"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "hmac_secret_key" {
  name        = "/backend/hmac_secret_key"
  value       = "replace me"
  type        = "SecureString"
  description = "hmac_secret_key"
  lifecycle {
    ignore_changes = [value]
  }
}