data "aws_route53_zone" "example" {
  name = module.constants.main_domain
}

resource "aws_route53_record" "cloudfront" {
  allow_overwrite = true
  name            = module.constants.frontend_domain
  //ttl             = 0
  type    = "A"
  zone_id = data.aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
  }
}