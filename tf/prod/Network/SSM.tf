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
//domain names
//resource "aws_ssm_parameter" "main_domain" {
//  name        = "/conf/main_domain"
//  value       = "ys-dev.net"
//  type        = "String"
//  description = "main_domain"
//}
//resource "aws_ssm_parameter" "backend_domain" {
//  name        = "/conf/backend_domain"
//  value       = "backend.music-tools.ys-dev.net"
//  type        = "String"
//  description = "backend_domain"
//}
//resource "aws_ssm_parameter" "frontend_domain" {
//  name        = "/conf/frontend_domain"
//  value       = "music-tools.ys-dev.net"
//  type        = "String"
//  description = "frontend_domain"
//}
////S3 bucket names
//resource "aws_ssm_parameter" "bucket_name_usermedia" {
//  name        = "/conf/bucket_name_usermedia"
//  value       = "music-tools-media-prod"
//  type        = "String"
//  description = "bucket_name_usermedia"
//}
//resource "aws_ssm_parameter" "bucket_name_access_log" {
//  name        = "/conf/bucket_name_access_log"
//  value       = "music-tools-access-log-prod"
//  type        = "String"
//  description = "bucket_name_access_log"
//}
//resource "aws_ssm_parameter" "bucket_name_frontend" {
//  name        = "/conf/bucket_name_frontend"
//  value       = "music-tools-frontend"
//  type        = "String"
//  description = "bucket_name_frontend"
//}
//db parameters
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