resource "aws_route53_zone" "example" {
  name = "ys-dev.net"
}
resource "aws_route53_zone" "subdomain" {
  name = "test.loopanalyzer.tk"
}
//DNSレコード
resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.example.id
  name    = data.aws_route53_zone.example.name
  //ALIASレコード, ipアドレスまたはAWSリソースにルーティング
  type = "A"

  //ELBへのルーティング
  alias {
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}
//検証用のDNSレコード
//サブドメイン追加してたら、その分も作る
resource "aws_route53_record" "example_certificate" {
  zone_id = data.aws_route53_zone.example.id
  name    = tolist(aws_acm_certificate.example.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.example.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.example.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

output "domain_name" {
  value = aws_route53_record.example.name
}