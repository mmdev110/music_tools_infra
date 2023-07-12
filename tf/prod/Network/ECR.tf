resource "aws_ecr_repository" "repository" {
  name         = "music_tools_backend"
  force_delete = true
}