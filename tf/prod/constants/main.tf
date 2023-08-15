locals {
  service_name = "music_tools"
  env          = "prod"

  main_domain     = "ys-dev.net"
  frontend_domain = "music-tools.ys-dev.net"
  backend_domain  = "backend.music-tools.ys-dev.net"
  backend_elb_domain  = "elb-backend.music-tools.ys-dev.net"

  bucket_name_usermedia = "music-tools-media-prod"
  bucket_name_alb_log   = "music-tools-access-log-prod"
  bucket_name_frontend  = "music-tools-frontend-prod"
  bucket_name_terraform = "music-tools-infra-prod"

  cloudwatch_backend_log="/music_tools/prod/backend"

  ecr_repository_name_backend="music_tools_backend"
  lambda_function_name="music_tools_lambda_convert_prod"

  mediaconvert_region="ap-northeast-1"
  mediaconvert_job_template_name="music_tools_convert_prod"
}
output "service_name" {
  value = local.service_name
}
output "env" {
  value = local.env
}
output "main_domain" {
  value = local.main_domain
}
output "frontend_domain" {
  value = local.frontend_domain
}
output "backend_domain" {
  value = local.backend_domain
}
output "backend_elb_domain" {
  value = local.backend_elb_domain
}
output "cloudwatch_backend_log" {
  value = local.cloudwatch_backend_log
}

output "bucket_name_usermedia" {
  value = local.bucket_name_usermedia
}
output "bucket_name_alb_log" {
  value = local.bucket_name_alb_log
}
output "bucket_name_frontend" {
  value = local.bucket_name_frontend
}
output "bucket_name_terraform" {
  value = local.bucket_name_terraform
}
output "ecr_repository_name_backend" {
  value = local.ecr_repository_name_backend
}
output "lambda_function_name" {
  value = local.lambda_function_name
}
output "mediaconvert_region" {
  value = local.mediaconvert_region
}
output "mediaconvert_job_template_name" {
  value = local.mediaconvert_job_template_name
}