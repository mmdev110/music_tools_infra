data "aws_ssm_parameter" "db_user" {
  name = "/music_tools/prod/db/db_user"
}
data "aws_ssm_parameter" "db_password" {
  name = "/music_tools/prod/db/db_password"
}
data "aws_ssm_parameter" "db_database" {
  name = "/music_tools/prod/db/db_database"
}