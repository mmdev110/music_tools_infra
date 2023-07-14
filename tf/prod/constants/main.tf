locals {
  main_domain     = "ys-dev.net"
  frontend_domain = "music-tools.ys-dev.net"
  backend_domain  = "backend.music-tools.ys-dev.net"

  bucket_name_usermedia = "music-tools-media-prod"
  bucket_name_alb_log   = "music-tools-access-log-prod"
  bucket_name_frontend  = "music-tools-frontend"
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

output "bucket_name_usermedia" {
  value = local.bucket_name_usermedia
}
output "bucket_name_alb_log" {
  value = local.bucket_name_alb_log
}
output "bucket_name_frontend" {
  value = local.bucket_name_frontend
}