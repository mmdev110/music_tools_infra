//データベースの設定
resource "aws_db_parameter_group" "db" {
  name        = "music-tools-prod-db-parameter-group"
  description = "DB parameter group for music-tools"
  family      = "mysql8.0"
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

//オプション機能、プラグイン
resource "aws_db_option_group" "db" {
  name                 = "music-tools-prod-db-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

resource "aws_db_subnet_group" "db" {
  name       = "music-tools-prod-db-subnet-group"
  subnet_ids = [aws_subnet.db0.id, aws_subnet.db1.id]
}
locals {
  snapshot_prefix = "music-tools-prod-db-snapshot"
  db_identifier   = "music-tools-prod-db"
}
//スナップショットから復元したい場合は
//aws_db_instance.db.snapshot_identifierとdata.aws_db_snapshot.recentのコメントを外す
resource "aws_db_instance" "db" {
  identifier            = local.db_identifier
  snapshot_identifier   = data.aws_db_snapshot.recent.id
  engine                = "mysql"
  engine_version        = "8.0.33"
  instance_class        = "db.t4g.micro"
  username              = aws_ssm_parameter.db_user.value
  password              = aws_ssm_parameter.db_password.value
  db_name               = aws_ssm_parameter.db_database.value
  availability_zone     = "ap-northeast-1a"
  storage_type          = "gp3"
  storage_encrypted     = true
  allocated_storage     = 20
  max_allocated_storage = 100
  multi_az              = false
  publicly_accessible   = false
  //multi_az            = false
  backup_window           = "09:10-09:40"
  backup_retention_period = 7
  //maintenance_window         = "mon:10:10-mon:10:40"
  //auto_minor_version_upgrade = false
  /*
  削除しないときは
  deletion_protection=true
  skip_final_snapshot=false
  削除するときは逆にする
  */
  deletion_protection       = false
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.snapshot_prefix}-${replace(timestamp(), ":", "-")}"
  port                      = 3306
  apply_immediately         = true
  vpc_security_group_ids    = [module.mysql_sg.security_group_id]
  option_group_name         = aws_db_option_group.db.name
  parameter_group_name      = aws_db_parameter_group.db.name
  db_subnet_group_name      = aws_db_subnet_group.db.name

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier,
      snapshot_identifier
    ]
  }
}
data "aws_db_snapshot" "recent" {
  db_instance_identifier = local.db_identifier
  most_recent            = true
}

//DBインスタンスのセキュリティグループ
module "mysql_sg" {
  source      = "../../modules/security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.service.id
  port        = 3306
  cidr_blocks = [aws_vpc.service.cidr_block]
}