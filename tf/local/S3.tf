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

resource "aws_s3_bucket_notification" "audio_put" {
  bucket = aws_s3_bucket.usermedia.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".wav"
  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".mp3"
  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".m4a"
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}