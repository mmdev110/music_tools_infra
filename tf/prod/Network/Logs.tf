//ECS用ログ
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/backend"
  retention_in_days = 180
}
