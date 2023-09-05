resource "aws_cloudwatch_log_group" "backend" {
  name              = module.constants.cloudwatch_backend_log
  retention_in_days = 180
}