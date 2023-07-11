data "aws_acm_certificate" "elb" {
  domain   = "ys-dev.net"
  statuses = ["ISSUED"]
}