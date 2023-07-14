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
  for_each = aws_acm_certificate.cloudfront.domain_validation_options
  zone_id  = aws_route53_zone.example.id
  name     = each.value.resource_record_name
  type     = each.value.resource_record_type
  records  = [each.value.resource_record_value]
  ttl      = 60
}

output "domain_name" {
  value = aws_route53_zone.example.name
}