resource "aws_s3_bucket" "usermedia" {
  bucket        = module.constants.bucket_name_usermedia
  force_destroy = true
  //versioning {
  //  enabled = true
  //}
}
resource "aws_s3_bucket_server_side_encryption_configuration" "usermedia" {
  bucket = module.constants.bucket_name_usermedia
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"

    }
  }
}
resource "aws_s3_bucket_cors_configuration" "usermedia" {
  bucket = module.constants.bucket_name_usermedia
  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_public_access_block" "usermedia" {
  bucket                  = module.constants.bucket_name_usermedia
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}