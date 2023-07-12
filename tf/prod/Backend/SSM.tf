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
resource "aws_ssm_parameter" "backend_url" {
  name        = "/backend/backend_url"
  value       = "backend-prod.music-tools.ys-dev.net"
  type        = "String"
  description = "backend url"
}
resource "aws_ssm_parameter" "frontend_url" {
  name        = "/backend/frontend_url"
  value       = "music-tools.ys-dev.net"
  type        = "String"
  description = "frontend url"
}
resource "aws_ssm_parameter" "media_bucket_name" {
  name        = "/backend/media_bucket_name"
  value       = "music-tools-media-prod"
  type        = "String"
  description = "S3 bucket name for uploaded media"
}
resource "aws_ssm_parameter" "mediaconvert_endpoint" {
  name        = "/backend/mediaconvert_endpoint"
  value       = "https://mpazqbhuc.mediaconvert.ap-northeast-1.amazonaws.com"
  type        = "String"
  description = "mediaconvert endpoint"
}
resource "aws_ssm_parameter" "cloudfront-domain" {
  name        = "/backend/cloudfront-domain"
  value       = "https://d9vtujh5rva21.cloudfront.net"
  type        = "String"
  description = "cloudfront domain"
}
#以下、手動で値を更新する必要があるパラメータ
resource "aws_ssm_parameter" "mysql_database" {
  name        = "/backend/mysql_database"
  value       = "replace me"
  type        = "SecureString"
  description = "database name"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "mysql_user" {
  name        = "/backend/mysql_user"
  value       = "replace me"
  type        = "SecureString"
  description = "mysql user"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "mysql_host" {
  name        = "/backend/mysql_host"
  value       = "replace me"
  type        = "SecureString"
  description = "mysql host"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "mysql_password" {
  name        = "/backend/mysql_password"
  value       = "replace me"
  type        = "SecureString"
  description = "mysql password"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "mysql_port" { #これは更新しなくていい
  name        = "/backend/mysql_port"
  value       = "3306"
  type        = "SecureString"
  description = "mysql port"
}
resource "aws_ssm_parameter" "hmac_secret_key" {
  name        = "/backend/hmac_secret_key"
  value       = "replace me"
  type        = "SecureString"
  description = "hmac secret key string"
  lifecycle {
    ignore_changes = [value]
  }
}