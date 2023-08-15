//ECS用ログ
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = module.constants.cloudwatch_backend_log
  retention_in_days = 180
}
