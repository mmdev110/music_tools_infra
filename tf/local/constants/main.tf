locals {
  service_name = "music_tools"
  env          = "local"

  frontend_domain = "localhost:3000"
  backend_domain  = "localhost:5000"

  bucket_name_usermedia = "music-tools-media-local"
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