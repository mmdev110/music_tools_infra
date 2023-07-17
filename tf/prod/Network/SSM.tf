//イメージアップロード用
resource "aws_ssm_parameter" "backend_ecr_registry_url" {
  name        = "/music_tools/prod/backend/backend_ecr_registry_url"
  value       = split("/", aws_ecr_repository.backend.repository_url)[0]
  type        = "String"
  description = "URL of ECR registry for backend"
}
resource "aws_ssm_parameter" "backend_ecr_repository_url" {
  name        = "/music_tools/prod/backend/backend_ecr_repository_url"
  value       = aws_ecr_repository.backend.repository_url
  type        = "String"
  description = "URL of ECR repository for backend"
}
//lambdaイメージアップロード用
resource "aws_ssm_parameter" "lambda_ecr_registry_url" {
  name        = "/music_tools/prod/backend/lambda_ecr_registry_url"
  value       = split("/", aws_ecr_repository.lambda.repository_url)[0]
  type        = "String"
  description = "URL of ECR registry for lambda"
}
resource "aws_ssm_parameter" "lambda_ecr_repository_url" {
  name        = "/music_tools/prod/backend/lambda_ecr_repository_url"
  value       = aws_ecr_repository.lambda.repository_url
  type        = "String"
  description = "URL of ECR repository for lambda"
}
//db parameters
resource "aws_ssm_parameter" "db_user" {
  name        = "/music_tools/prod/db/db_user"
  value       = "replace me"
  type        = "SecureString"
  description = "db user"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "db_password" {
  name        = "/music_tools/prod/db/db_password"
  value       = "replace me"
  type        = "SecureString"
  description = "db password"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "db_database" {
  name        = "/music_tools/prod/db/db_database"
  value       = "replace me"
  type        = "SecureString"
  description = "db database"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "hmac_secret_key" {
  name        = "/music_tools/prod/backend/hmac_secret_key"
  value       = "replace me"
  type        = "SecureString"
  description = "hmac_secret_key"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "mediaconvert_endpoint" {
  name        = "/music_tools/prod/backend/mediaconvert_endpoint"
  value       = "replace me"
  type        = "SecureString"
  description = "mediaconvert_endpoint for prod"
  lifecycle {
    ignore_changes = [value]
  }
}