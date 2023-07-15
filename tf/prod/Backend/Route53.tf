data "aws_route53_zone" "example" {
  name = module.constants.main_domain
}

resource "aws_route53_record" "elb" {
  allow_overwrite = true
  name            = module.constants.backend_elb_domain
  //ttl             = 0
  type    = "A"
  zone_id = data.aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_lb.backend.dns_name
    zone_id                = aws_lb.backend.zone_id
  }
}
resource "aws_route53_record" "cloudfront" {
  allow_overwrite = true
  name            = module.constants.backend_domain
  //ttl             = 0
  type    = "A"
  zone_id = data.aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.backend.domain_name
    zone_id                = aws_cloudfront_distribution.backend.hosted_zone_id
  }
}