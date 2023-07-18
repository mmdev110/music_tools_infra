data "aws_acm_certificate" "cloudfront" {
  provider = aws.us
  domain   = module.constants.main_domain
  statuses = ["ISSUED"]
}