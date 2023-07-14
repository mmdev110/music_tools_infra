resource "aws_route53_zone" "example" {
  name = local.main_domain
  lifecycle {
    prevent_destroy = true
  }
}
//resource "aws_route53_zone" "subdomain" {
//  name = "test.loopanalyzer.tk"
//}
//DNSレコード
//resource "aws_route53_record" "example" {
//  zone_id = aws_route53_zone.example.id
//  name    = aws_route53_zone.example.name
//  //ALIASレコード, ipアドレスまたはAWSリソースにルーティング
//  type = "A"
//
//  //ELBへのルーティング
//  alias {
//    name                   = aws_lb.example.dns_name
//    zone_id                = aws_lb.example.zone_id
//    evaluate_target_health = true
//  }
//}

//検証用のDNSレコード
//サブドメイン追加してたら、その分も作る
resource "aws_route53_record" "cloudfront_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.example.zone_id
}

output "domain_name" {
  value = aws_route53_zone.example.name
}