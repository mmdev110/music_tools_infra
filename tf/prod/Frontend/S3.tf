data "aws_s3_bucket" "frontend" {
  bucket = module.constants.bucket_name_frontend
}
//cloudfrontからの接続に必要なバケットポリシー更新
resource "aws_s3_bucket_policy" "allow_access_via_cloudfront" {
  bucket = data.aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.allow_access_via_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_via_cloudfront" {
  policy_id = "allow_access_via_cloudfront"
  statement {
    sid    = "allow_access_via_cloudfront"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.frontend.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend.arn]
    }
  }
}