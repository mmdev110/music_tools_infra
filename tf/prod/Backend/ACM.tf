data "aws_acm_certificate" "elb" {
  domain   = "ys-dev.net"
  statuses = ["ISSUED"]
}
data "aws_acm_certificate" "cloudfront" {
  provider = aws.us
  domain   = "ys-dev.net"
  statuses = ["ISSUED"]
}