locals{
bucket_name_usermedia="music-tools-media-prod"
bucket_name_alb_log="music-tools-access-log-prod"
bucket_name_secrets="music-tools-secrets-prod"
bucket_name_frontend="music-tools-frontend-prod"
}
resource "aws_s3_bucket" "usermedia" {
  bucket        = locals.bucket_name_usermedia
  force_destroy = true
  //versioning {
  //  enabled = true
  //}
}
resource "aws_s3_bucket_server_side_encryption_configuration" "usermedia" {
  bucket = locals.bucket_name_usermedia
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"

    }
  }
}
resource "aws_s3_bucket_cors_configuration" "usermedia" {
  bucket = locals.bucket_name_usermedia
  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_public_access_block" "usermedia" {
  bucket                  = locals.bucket_name_usermedia
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

//ALBアクセスログ
resource "aws_s3_bucket" "alb_log" {
  bucket        = locals.bucket_name_alb_log
  force_destroy = true
}
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = locals.bucket_name_alb_log
  policy = data.aws_iam_policy_document.alb_log.json
  depends_on = [
    aws_s3_bucket.alb_log
  ]
}
data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${locals.bucket_name_alb_log}/*"]
    principals {
      type = "AWS"
      //ELBアカウントID(ap-northeast-1)
      identifiers = ["582318560864"]
    }
  }
}

//secrets保管用
resource "aws_s3_bucket" "secrets" {
  bucket        = locals.bucket_name_secrets
  force_destroy = true
  //versioning {
  //  enabled = true
  //}
}
resource "aws_s3_bucket_server_side_encryption_configuration" "secrets" {
  bucket = locals.bucket_name_secrets
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"

    }
  }
}
resource "aws_s3_bucket_public_access_block" "secrets" {
  bucket                  = locals.bucket_name_secrets
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
//frontend
resource "aws_s3_bucket" "frontend" {
  bucket        = locals.bucket_name_frontend
  force_destroy = true
  //versioning {
  //  enabled = true
  //}
}