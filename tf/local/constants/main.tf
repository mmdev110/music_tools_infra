locals {
  service_name = "music_tools"
  env          = "local"

  frontend_domain = "localhost:3000"
  backend_domain  = "localhost:5000"

  bucket_name_usermedia = "music-tools-media-local"

  lambda_function_name="music_tools_convert_local"
  ecr_repository_name="music_tools_convert_lambda_local"
}
output "service_name" {
  value = local.service_name
}
output "env" {
  value = local.env
}
output "frontend_domain" {
  value = local.frontend_domain
}
output "backend_domain" {
  value = local.backend_domain
}
output "bucket_name_usermedia" {
  value = local.bucket_name_usermedia
}
output "lambda_function_name" {
  value = local.lambda_function_name
}
output "ecr_repository_name" {
  value = local.ecr_repository_name
}