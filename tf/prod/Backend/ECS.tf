resource "aws_ecs_cluster" "backend_cluster" {
  name = "music_tools_backend_cluster"
}
//サービス
//タスクの長期稼働、ELBとの連携
resource "aws_ecs_service" "backend" {
  name = "backend"
  //クラスターとタスク定義を指定
  cluster         = aws_ecs_cluster.backend_cluster.arn
  task_definition = aws_ecs_task_definition.backend.arn
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
      aws_subnet.public0.id
    ]
  }
  //ELBとの紐付け、ターゲットグループへの登録
  //load_balancer {
  //  target_group_arn = aws_lb_target_group.example.arn
  //  container_name   = "backend"
  //  container_port   = 5000
  //}

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      "name" : "backend",
      "image" : "${aws_ecr_repository.repository.repository_url}:latest",
      "essential" : true,
      "portMappings" : [
        {
          "protocol" : "tcp",
          "containerPort" : 5000
        },
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "nginx",
          "awslogs-group" : "/ecs/backend"
        }
      },
      "environment" : [
        {
          "name" : "MYSQL_DATABASE",
          "valueFrom" : "/backend/mysql_database",
        },
      ],
      "command" : ["/output"]
    }
  ])
} //ECSに付与するIAMロール
module "ecs_task_execution_role" {
  source     = "../iam_role"
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
module "nginx_sg" {
  source      = "../security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.service.id
  port        = 80
  cidr_blocks = [aws_vpc.service.cidr_block]
}