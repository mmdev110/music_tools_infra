variable "bucket_name_usermedia" {
  default = "loopthatloop-usermedia-prod"
}
variable "bucket_name_alb_log" {
  default = "loopthatloop-log-prod"
}

resource "aws_s3_bucket" "private" {
  bucket        = var.bucket_name_usermedia
  force_destroy = true
  //versioning {
  //  enabled = true
  //}
}
resource "aws_s3_bucket_server_side_encryption_configuration" "private" {
  bucket = var.bucket_name_usermedia
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"

    }
  }
}
resource "aws_s3_bucket_cors_configuration" "private" {
  bucket = var.bucket_name_usermedia
  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = var.bucket_name_usermedia
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


//ALBアクセスログ
resource "aws_s3_bucket" "alb_log" {
  bucket        = var.bucket_name_alb_log
  force_destroy = true
}
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = var.bucket_name_alb_log
  policy = data.aws_iam_policy_document.alb_log.json
  depends_on = [
    aws_s3_bucket.alb_log
  ]
}
data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name_alb_log}/*"]
    principals {
      type = "AWS"
      //ELBアカウントID(ap-northeast-1)
      identifiers = ["582318560864"]
    }
  }
}
