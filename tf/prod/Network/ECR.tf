resource "aws_ecr_repository" "backend" {
  name         = module.constants.ecr_repository_name_backend
  force_delete = true
}
resource "aws_ecr_repository" "lambda" {
  name         = module.constants.lambda_function_name
  force_delete = true
}