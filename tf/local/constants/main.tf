locals {
  service_name = "music_tools"
  env          = "local"
  email_domain ="ys-dev.net"
  frontend_domain = "localhost:3000"
  backend_domain  = "localhost:5000"

  support_email_address="support@music-tools.ys-dev.net"

  bucket_name_usermedia = "music-tools-media-local"

  lambda_function_name="music_tools_convert_local"
  ecr_repository_name="music_tools_convert_lambda_local"

  cognito_user_pool_name="music-tools-local"
}
output "service_name" {
  value = local.service_name
}
output "env" {
  value = local.env
}
output "email_domain" {
  value = local.email_domain
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
output "cognito_user_pool_name"{
  value = local.cognito_user_pool_name
}

output "support_email_address"{
  value = local.support_email_address
}