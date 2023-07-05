//クラスタ
//タスク、サービスを束ねたもの
resource "aws_ecs_cluster" "example" {
  name = "example"
}
//タスク
//実行単位
//タスク定義
//タスクを生成するための定義
resource "aws_ecs_task_definition" "example" {
  family                   = "example" //タスク定義のprefix
  cpu                      = "256"     //整数値またはvCPU
  memory                   = "512"     //整数値またはGB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}
//サービス
//タスクの長期稼働、ELBとの連携
resource "aws_ecs_service" "example" {
  name = "example"
  //クラスターとタスク定義を指定
  cluster         = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.example.arn
  //維持するタスク数
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.3.0"
  //起動からヘルスチェック開始までの待ち時間
  health_check_grace_period_seconds = 60

  //どこにタスクを配置するか？
  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.web0.id,
      aws_subnet.web1.id
    ]
  }
  //ELBとの紐付け、ターゲットグループへの登録
  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.service.id
  port        = 80
  cidr_blocks = [aws_vpc.service.cidr_block]
}

//ECSに付与するIAMロール
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs_task_execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}
//プリセットがあるのでそれを使用する
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  //既存ポリシーを継承
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}