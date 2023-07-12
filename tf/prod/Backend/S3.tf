locals {
  bucket_name_usermedia = "music-tools-media-prod"
  bucket_name_alb_log   = "music-tools-access-log-prod"
  bucket_name_secrets   = "music-tools-secrets-prod"
  bucket_name_frontend  = "music-tools-frontend-prod"
}
data "aws_s3_bucket" "alb_log" {
  bucket = local.bucket_name_alb_log
}
data "aws_s3_bucket" "secrets" {
  bucket = local.bucket_name_secrets
}