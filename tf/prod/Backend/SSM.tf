//SSM
//環境変数の管理
//tfファイルにsecretなどの値を書けないので
//terraformで仮の値でリソースを作っておき、CLIから実際の値で上書きする
//平文
//aws ssm get-parameter --output text --name 'plain_name' --query Parameter.Value
//aws ssm put-parameter --name 'plain_name' --value 'plain value' --type String --overwrite
//暗号化された値
//aws ssm get-parameter --output text --name 'plain_name' --query Parameter.Value --with_descryption
//aws ssm put-parameter --name 'encryption_name' --value 'encryption value' --type "SecureString" --overwrite

resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "データベースのユーザー名"
}
resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  value       = "InitialPassword"
  type        = "SecureString"
  description = "パスワード(暗号化)"
  lifecycle {
    ignore_changes = [value]
  }
}