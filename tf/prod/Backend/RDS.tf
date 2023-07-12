//データベースの設定
resource "aws_rds_cluster_parameter_group" "db" {
  name        = "music-tools-db-cluster-parameter-group"
  family      = "aurora-mysql8.0"
  description = "DB cluster parameter group for music-tools"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
resource "aws_db_parameter_group" "db" {
  name        = "music-tools-db-parameter-group"
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
}

//オプション機能、プラグイン
resource "aws_db_option_group" "db" {
  name                 = "music-tools-db-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}
resource "aws_db_subnet_group" "db" {
  name       = "subnets"
  subnet_ids = [data.aws_subnet.db0.id, data.aws_subnet.db1.id]
}

resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier = "music-tools-db"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.03.1"
  engine_mode        = "provisioned"
  //kms_key_id     = aws_kms_key.example.arn
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
  master_username = data.aws_ssm_parameter.db_user.value
  //パスワードは仮置きして後で更新する
  /*
  aws rds modify-db-instance --db-instance-identifier "example" --master-user-password "NewMasterPassword!"
  */
  master_password = data.aws_ssm_parameter.db_password.value
  database_name   = data.aws_ssm_parameter.db_database.value
  //multi_az            = false
  //backup_window              = "09:10-09:40"
  //backup_retention_period    = 30
  //maintenance_window         = "mon:10:10-mon:10:40"
  //auto_minor_version_upgrade = false
  /*
  削除しないときは
  deletion_protection=true
  skip_final_snapshot=false
  削除するときは逆にする
  */
  deletion_protection             = false
  skip_final_snapshot             = true
  port                            = 3306
  apply_immediately               = true
  vpc_security_group_ids          = [module.mysql_sg.security_group_id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db.name
  //option_group_name               = aws_db_option_group.db.name
  db_subnet_group_name = aws_db_subnet_group.db.name

  lifecycle {
    ignore_changes = [master_password]
  }
}
resource "aws_rds_cluster_instance" "db" {
  cluster_identifier  = aws_rds_cluster.db_cluster.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.db_cluster.engine
  engine_version      = aws_rds_cluster.db_cluster.engine_version
  publicly_accessible = false

}

//DBインスタンスのセキュリティグループ
module "mysql_sg" {
  source      = "../security_group"
  name        = "mysql-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 3306
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}

output "endpoint" {
  value = aws_rds_cluster.db_cluster.endpoint
}
output "reader_endpoint" {
  value = aws_rds_cluster.db_cluster.reader_endpoint
}