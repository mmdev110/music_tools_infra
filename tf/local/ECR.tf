resource "aws_ecr_repository" "repository" {
  name         = module.constants.ecr_repository_name
  force_delete = true
}