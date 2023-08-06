locals {
  secrets_file_name = "app.prod.env"
}
data "aws_ecr_repository" "backend" {
  name = module.constants.ecr_repository_name_backend
}

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
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  //起動からヘルスチェック開始までの待ち時間
  health_check_grace_period_seconds = 60

  //どこにタスクを配置するか？
  network_configuration {
    assign_public_ip = false
    security_groups = [
      module.http_sg.security_group_id,
      module.https_sg.security_group_id,
      module.golang_sg.security_group_id
    ]

    subnets = [
      data.aws_subnet.web0.id,
      //data.aws_subnet.web1.id
    ]
  }
  //ELBとの紐付け、ターゲットグループへの登録
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 5000
  }

  //lifecycle {
  //  ignore_changes = [task_definition]
  //}
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  task_role_arn            = module.ecs_backend_role.iam_role_arn
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      "name" : "backend",
      "image" : "${data.aws_ecr_repository.backend.repository_url}:latest",
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
          "awslogs-stream-prefix" : "backend",
          "awslogs-group" : module.constants.cloudwatch_backend_log
        }
      },
      "environment" : [
        {
          "name" : "ENV",
          "value" : "prod",
        },
        {
          "name" : "BACKEND_URL",
          "value" : "https://${module.constants.backend_domain}",
        },
        {
          "name" : "FRONTEND_URL",
          "value" : "https://${module.constants.frontend_domain}",
        },
        {
          "name" : "MYSQL_PORT",
          "value" : "3306",
        },
        //{
        //  "name" : "AWS_ACCESS_KEY_ID",
        //  "value" : "",
        //},
        //{
        //  "name" : "AWS_SECRET_ACCESS_KEY",
        //  "value" : "",
        //},
        {
          "name" : "AWS_BUCKET_NAME",
          "value" : module.constants.bucket_name_usermedia,
        },
        {
          "name" : "AWS_MEDIACONVERT_ENDPOINT",
          "value" : "https://mpazqbhuc.mediaconvert.ap-northeast-1.amazonaws.com",
        },
        {
          "name" : "AWS_CLOUDFRONT_DOMAIN",
          "value" : "https://d9vtujh5rva21.cloudfront.net",
        },
        {
          "name" : "AWS_REGION",
          "value" : "ap-northeast-1",
        },
        {
          "name" : "SUPPORT_EMAIL_DOMAIN",
          "value" : "music-tools.ys-dev.net",
        },
      ],
      "secrets" : [
        {
          "name" : "MYSQL_ROOT_PASSWORD",
          "valueFrom" : "/music_tools/prod/db/db_password",
        },
        {
          "name" : "MYSQL_DATABASE",
          "valueFrom" : "/music_tools/prod/db/db_database",
        },
        {
          "name" : "MYSQL_USER",
          "valueFrom" : "/music_tools/prod/db/db_user",
        },
        {
          "name" : "MYSQL_PASSWORD",
          "valueFrom" : "/music_tools/prod/db/db_password",
        },
        {
          "name" : "HMAC_SECRET_KEY",
          "valueFrom" : "/music_tools/prod/backend/hmac_secret_key",
        },
        {
          "name" : "MYSQL_HOST",
          "valueFrom" : "/music_tools/prod/db/db_host",
        },
      ],
      "command" : ["/output"]
    }
  ])
  depends_on = [aws_instance.nat]
}
//ECSに付与するIAMロール
module "ecs_task_execution_role" {
  source     = "../../modules/iam_role"
  name       = "music_tools_ecs_execution_role_prod"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}
module "ecs_backend_role" {
  source     = "../../modules/iam_role"
  name       = "music_tools_ecs_backend_role_prod"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_backend.json
}
//プリセットがあるのでそれを使用する
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  //既存ポリシーを継承
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt",
      //"s3:GetObject",
      //"s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${data.aws_s3_bucket.usermedia.arn}/*"]
  }
}
data "aws_iam_policy_document" "ecs_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${data.aws_s3_bucket.usermedia.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["*"]
  }
}