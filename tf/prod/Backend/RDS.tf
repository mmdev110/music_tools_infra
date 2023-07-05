//DB設定(my.cnf)
resource "aws_db_parameter_group" "example" {
  name   = "example"
  family = "mysql5.7"
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}
//DBオプショングループ
//プラグイン追加など
resource "aws_db_option_group" "example" {
  name                 = "example"
  engine_name          = "mysql"
  major_engine_version = "5.7"
  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}
//DBサブネットグループ
//DBを置くサブネット群を指定する
resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.db0.id, aws_subnet.db1.id]
}
resource "aws_db_instance" "example" {
  //エンドポイントで使う識別子(?)
  identifier     = "example"
  engine         = "mysql"
  engine_version = "5.7.40"
  //tier
  instance_class        = "db.t3.small"
  storage_type          = "gp2" //汎用SSD
  allocated_storage     = 20    //20GB
  max_allocated_storage = 100   //ここまで自動的にスケール
  //KMSによるディスク暗号化
  storage_encrypted = true
  kms_key_id        = aws_kms_key.example.arn
  //マスターユーザー
  username = "admin"
  //パスワードは仮置きして後で更新する
  /*
  aws rds modify-db-instance --db-instance-identifier "example" --master-user-password "NewMasterPassword!"
  */
  password                   = "VeryStrongPassword!"
  multi_az                   = true                  //マルチAZ有効
  publicly_accessible        = false                 //publicアクセス無効
  backup_window              = "09:10-09:40"         //バックアップ(UTC)
  backup_retention_period    = 30                    //バックアップ保持日数
  maintenance_window         = "mon:10:10-mon:10:40" //メンテナンスタイミング(UTC)
  auto_minor_version_upgrade = false                 //マイナーバージョンアップの無効化
  //削除するときは以下をfalse,true
  deletion_protection = false
  skip_final_snapshot = true
  //削除しないときは上をtrue,falseにする
  port                   = 3306                                //デフォルトポート3306
  apply_immediately      = false                               //設定変更を即時反映しない(メンテナンスウィンドウで行う)
  vpc_security_group_ids = [module.mysql_sg.security_group_id] //セキュリティグループ
  parameter_group_name   = aws_db_parameter_group.example.name
  option_group_name      = aws_db_option_group.example.name
  db_subnet_group_name   = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [password]
  }
}
//3306のingress許可
module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.service.id
  port        = 3306
  cidr_blocks = [aws_vpc.service.cidr_block]
}