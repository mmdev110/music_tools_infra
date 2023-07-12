data "aws_ssm_parameter" "db_user" {
  name = "/db/db_user"
}
data "aws_ssm_parameter" "db_password" {
  name = "/db/db_password"
}
data "aws_ssm_parameter" "db_database" {
  name = "/db/db_database"
}