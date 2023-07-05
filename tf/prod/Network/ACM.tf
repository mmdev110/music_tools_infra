//https化のためのSSL証明書作成

resource "aws_acm_certificate" "example" {
  domain_name = aws_route53_record.example.name
  //ドメイン名を追加したい場合以下に指定(mydomain.comに加えてtest.mydomain.comも追加したいなど)
  subject_alternative_names = []
  //検証方法
  //DNS検証かEメール検証
  validation_method = "DNS"
  lifecycle {
    //新しいものを作ってから古い証明書と差し替えるようにする
    create_before_destroy = true
  }
}

//検証完了まで待機するためのリソース
resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}