//ELB
resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "application" //ALB
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [aws_subnet.public0.id, aws_subnet.public1.id]
  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }
  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id
  ]
}
//listener
//どのポートのリクエストを受け付けるか
//これに加えてsecurity_groupで対象ポートへのingressを許可しておく必要あり
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  //httpでポート80にアクセスが来た場合
  port     = "80"
  protocol = "HTTP"
  //リダイレクト
  default_action {
    type = "redirect"
    redirect {
      port     = "443"
      protocol = "HTTPS"
      //301コード
      status_code = "HTTP_301"
    }
  }
}
//resource "aws_lb_listener" "https" {
//  load_balancer_arn = aws_lb.example.arn
//  port              = "443"
//  protocol          = "HTTPS"
//  //作成した証明書をアタッチ
//  certificate_arn = aws_acm_certificate.example.arn
//  //https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
//  ssl_policy = "ELBSecurityPolicy-2016-08"
//
//  //リスナールールにマッチしない場合の挙動
//  default_action {
//    //固定レスポンス
//    type = "fixed-response"
//    fixed_response {
//      content_type = "text/plain"
//      message_body = "これはHTTPSです"
//      status_code  = 200
//    }
//  }
//}
//リスナールール
//listenerとtarget_groupの紐付け
//resource "aws_lb_listener_rule" "https" {
//  listener_arn = aws_lb_listener.https.arn
//  priority     = 100
//  action {
//    type             = "forward"
//    target_group_arn = aws_lb_target_group.example.arn
//  }
//  //マッチ条件
//  //全てのリクエストを指定したターゲットグループに流す
//  condition {
//    path_pattern {
//      values = ["/*"]
//    }
//  }
//}
//listenerとtarget_groupの紐付け
resource "aws_lb_listener_rule" "http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
  //マッチ条件
  //全てのリクエストを指定したターゲットグループに流す
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
//ターゲットグループ
//リクエストのフォワード先
//具体的なフォワード先はECSなどから登録する
resource "aws_lb_target_group" "example" {
  name        = "example"
  target_type = "ip"
  vpc_id      = aws_vpc.service.id
  //内部の通信はhttpで良い
  port     = 80
  protocol = "HTTP"
  //登録解除前の待機時間
  deregistration_delay = 300
  //ヘルスチェックの挙動
  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200            //status200が返ればhealthyと見なす
    port                = "traffic-port" //portで指定したport番号をそのまま使用
    protocol            = "HTTP"
  }
  depends_on = [aws_lb.example]
}
//security group
module "http_sg" {
  //外部から80ポートへのingressを許可(http)
  source      = "./security_group"
  name        = "http-sg"
  vpc_id      = aws_vpc.service.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
module "https_sg" {
  //外部から443ポートへのingressを許可(https)
  source      = "./security_group"
  name        = "https-sg"
  vpc_id      = aws_vpc.service.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}
