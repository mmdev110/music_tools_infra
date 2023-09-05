//backend
locals {
  origin_id = "backend_elb"
}
resource "aws_cloudfront_distribution" "backend" {
  origin {
    domain_name         = module.constants.backend_elb_domain
    origin_id           = local.origin_id
    connection_attempts = 3
    connection_timeout  = 10
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  comment         = "distribution for music_tools_backend"

  //logging_config {
  //  include_cookies = false
  //  bucket          = "mylogs.s3.amazonaws.com"
  //  prefix          = "myprefix"
  //}

  aliases = [module.constants.backend_domain]

  default_cache_behavior {
    compress                 = false
    allowed_methods          = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.no_cache.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    max_ttl                  = 0
    min_ttl                  = 0
    default_ttl              = 0
    target_origin_id         = local.origin_id

    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  retain_on_delete = false

  tags = {
    Name = "music_tools_backend"
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cloudfront.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

data "aws_cloudfront_cache_policy" "no_cache" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_route53_record" "cloudfront" {
  allow_overwrite = true
  name            = module.constants.backend_domain
  //ttl             = 0
  type    = "A"
  zone_id = aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.backend.domain_name
    zone_id                = aws_cloudfront_distribution.backend.hosted_zone_id
  }
}