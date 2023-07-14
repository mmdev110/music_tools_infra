//https化のためのSSL証明書作成
//cloudfront用の証明書
//us-east-1で作る必要あり
resource "aws_acm_certificate" "cloudfront" {
  provider    = aws.us
  domain_name = aws_route53_zone.example.name
  //ドメイン名を追加したい場合以下に指定(mydomain.comに加えてtest.mydomain.comも追加したいなど)
  subject_alternative_names = [module.constants.backend_domain, module.constants.frontend_domain]
  //検証方法
  //DNS検証かEメール検証
  validation_method = "DNS"
  lifecycle {
    //新しいものを作ってから古い証明書と差し替えるようにする
    create_before_destroy = true
  }
}

//検証完了まで待機するためのリソース
resource "aws_acm_certificate_validation" "cloudfront" {
  provider                = aws.us
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_certificate : record.fqdn]
}

//ELB用の証明書
//ELBと同じregionで作る必要あり
resource "aws_acm_certificate" "elb" {
  domain_name = aws_route53_zone.example.name
  //ドメイン名を追加したい場合以下に指定(mydomain.comに加えてtest.mydomain.comも追加したいなど)
  subject_alternative_names = [module.constants.backend_domain, module.constants.frontend_domain]
  //検証方法
  //DNS検証かEメール検証
  validation_method = "DNS"
  lifecycle {
    //新しいものを作ってから古い証明書と差し替えるようにする
    create_before_destroy = true
  }
}

//検証完了まで待機するためのリソース
resource "aws_acm_certificate_validation" "elb" {
  certificate_arn         = aws_acm_certificate.elb.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_certificate : record.fqdn]
}