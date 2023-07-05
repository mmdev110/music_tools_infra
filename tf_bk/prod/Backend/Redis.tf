//Redis(ElastiCache)
resource "aws_elasticache_parameter_group" "example" {
  name   = "example"
  family = "redis6.x"
  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}
//サブネットグループ
resource "aws_elasticache_subnet_group" "example" {
  name = "example"
  //マルチAZ
  subnet_ids = [aws_subnet.web0.id, aws_subnet.web1.id]
}
//レプリケーショングループ
//RDSのaws_db_instanceと似てる
resource "aws_elasticache_replication_group" "example" {
  replication_group_id       = "example"
  description                = "Cluster Disabled"
  engine                     = "redis" //"redis" or "memocached"
  engine_version             = "6.2"
  num_cache_clusters         = 3 //プライマリが1つレプリカが2つ
  node_type                  = "cache.t4g.medium"
  snapshot_window            = "09:10-10:10" //UTC
  snapshot_retention_limit   = 7             //保持期間
  maintenance_window         = "mon:10:40-mon:11:40"
  automatic_failover_enabled = true //フェイルオーバー。subnet_group設定が必要
  port                       = 6379 //デフォルト6379
  apply_immediately          = false
  security_group_ids         = [module.redis_sg.security_group_id]
  //パラメータグループ、サブネットグループの紐付け
  parameter_group_name = aws_elasticache_parameter_group.example.name
  subnet_group_name    = aws_elasticache_subnet_group.example.name
}
//6379のingress許可
module "redis_sg" {
  source      = "./security_group"
  name        = "redis-sg"
  vpc_id      = aws_vpc.service.id
  port        = 6379
  cidr_blocks = [aws_vpc.service.cidr_block]
}
