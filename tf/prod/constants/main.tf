//locals編集したらoutputも編集すること
locals {
  //全般
  service_name = "music_tools"
  env          = "prod"
  main_domain     = "ys-dev.net"
  bucket_name_terraform = "music-tools-infra-prod"

  //backend
  backend_domain  = "backend.music-tools.ys-dev.net"
  backend_elb_domain  = "elb-backend.music-tools.ys-dev.net"
  bucket_name_alb_log   = "music-tools-access-log-prod"
  cloudwatch_backend_log="/music_tools/prod/backend"
  ecr_repository_name_backend="music_tools_backend"

  //frontend
  frontend_domain = "music-tools.ys-dev.net"
  bucket_name_frontend  = "music-tools-frontend-prod"

  //lambda(media_convert)
  bucket_name_usermedia = "music-tools-media-prod"
  lambda_name_mediaconvert="music_tools_convert_prod"
  mediaconvert_region="ap-northeast-1"
  mediaconvert_job_template_name="music_tools_convert_prod"

  //lambda(backend_manager)
  backend_manager_domain  = "manager-backend.music-tools.ys-dev.net"
  lambda_name_manager="music_tools_backend_manager_prod"
  ecr_repository_name_backend_manager="music_tools_backend_manager_prod"
}
//全般
output "service_name" {
  value = local.service_name
}
output "env" {
  value = local.env
}
output "main_domain" {
  value = local.main_domain
}
output "bucket_name_terraform" {
  value = local.bucket_name_terraform
}
//backend
output "backend_domain" {
  value = local.backend_domain
}
output "backend_elb_domain" {
  value = local.backend_elb_domain
}
output "cloudwatch_backend_log" {
  value = local.cloudwatch_backend_log
}
output "bucket_name_alb_log" {
  value = local.bucket_name_alb_log
}
output "ecr_repository_name_backend" {
  value = local.ecr_repository_name_backend
}
//frontend
output "frontend_domain" {
  value = local.frontend_domain
}
output "bucket_name_frontend" {
  value = local.bucket_name_frontend
}

//lambda(media_convert)
output "bucket_name_usermedia" {
  value = local.bucket_name_usermedia
}
output "lambda_name_mediaconvert" {
  value = local.lambda_name_mediaconvert
}
output "mediaconvert_region" {
  value = local.mediaconvert_region
}
output "mediaconvert_job_template_name" {
  value = local.mediaconvert_job_template_name
}

//lambda(backend_manager)
output "backend_manager_domain" {
  value = local.backend_manager_domain
}
output "lambda_name_manager" {
  value = local.lambda_name_manager
}
output "ecr_repository_name_backend_manager" {
  value = local.ecr_repository_name_backend_manager
}