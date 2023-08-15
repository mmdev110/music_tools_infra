//aws_lb: ロードバランサー本体
//  aws_lb_listener: 受付ポートとデフォルト動作
//    aws_lb_listener_rule: アクセスが来た時、どこに流すか
//      aws_lb_target_group: アクセスの流し先

//ELB
resource "aws_lb" "backend" {
  name                       = "backend"
  load_balancer_type         = "application" //ALB
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    data.aws_subnet.public0.id,
    data.aws_subnet.public1.id
  ]
  access_logs {
    bucket  = data.aws_s3_bucket.alb_log.id
    enabled = true
  }
  security_groups = [
    module.http_sg_public.security_group_id,
    module.https_sg_public.security_group_id
  ]
}
//listener
//どのポートのリクエストを受け付けるか
//これに加えてsecurity_groupで対象ポートへのingressを許可しておく必要あり
resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn = aws_lb.backend.arn
  //httpでポート80にアクセスが来た場合
  port     = "80"
  protocol = "HTTP"
  //ルールにマッチしなければ、リダイレクト
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
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "443"
  protocol          = "HTTPS"
  //作成した証明書をアタッチ
  certificate_arn = data.aws_acm_certificate.elb.arn
  //https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  ssl_policy = "ELBSecurityPolicy-2016-08"

  //リスナールールにマッチしない場合の挙動
  default_action {
    //固定レスポンス
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これはHTTPSです"
      status_code  = 200
    }
  }
}
//リスナールール
//listenerとtarget_groupの紐付け
resource "aws_lb_listener_rule" "https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
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
resource "aws_lb_target_group" "backend" {
  name        = "backend"
  target_type = "ip" //ECS Fargateに振り分ける場合はip
  vpc_id      = data.aws_vpc.service.id
  //内部の通信はhttpで良い
  port     = 5000
  protocol = "HTTP"
  //登録解除前の待機時間
  deregistration_delay = 300
  //ヘルスチェックの挙動
  health_check {
    path                = "/_chk"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200            //status200が返ればhealthyと見なす
    port                = "traffic-port" //portで指定したport番号をそのまま使用
    protocol            = "HTTP"
  }
  depends_on = [aws_lb.backend]
}


output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}
