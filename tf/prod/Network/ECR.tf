resource "aws_ecr_repository" "backend" {
  name         = module.constants.ecr_repository_name_backend
  force_delete = true
}
resource "aws_ecr_repository" "lambda_mediaconvert" {
  name         = module.constants.lambda_name_mediaconvert
  force_delete = true
}
resource "aws_ecr_repository" "lambda_backend_manager" {
  name         = module.constants.lambda_name_manager
  force_delete = true
}