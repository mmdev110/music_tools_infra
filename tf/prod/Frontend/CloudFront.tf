//backend
locals {
  origin_id = "music_tools_frontend_prod"
}
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = data.aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
    connection_attempts      = 3
    connection_timeout       = 10
    //custom_origin_config {
    //  http_port              = 80
    //  https_port             = 443
    //  origin_protocol_policy = "https-only"
    //  origin_ssl_protocols   = ["TLSv1.2"]
    //}
  }
  default_root_object = "index.html"


  enabled         = true
  is_ipv6_enabled = false
  comment         = "distribution for music_tools_frontend prod"

  //logging_config {
  //  include_cookies = false
  //  bucket          = "mylogs.s3.amazonaws.com"
  //  prefix          = "myprefix"
  //}

  aliases = [module.constants.frontend_domain]

  default_cache_behavior {
    compress         = false
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = data.aws_cloudfront_cache_policy.caching_optimized.id
    max_ttl          = 0
    min_ttl          = 0
    default_ttl      = 0
    target_origin_id = local.origin_id

    viewer_protocol_policy = "redirect-to-https"
  }
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 504
    response_code         = 200
    response_page_path    = "/index.html"
  }
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  retain_on_delete    = false
  wait_for_deployment = true

  tags = {
    Name = "music_tools_frontend"
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.cloudfront.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = module.constants.bucket_name_frontend
  description                       = module.constants.bucket_name_frontend
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}