
module "nginx_sg" {
  source      = "../../modules/security_group"
  name        = "nginx-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 80
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}
module "golang_sg" {
  source      = "../../modules/security_group"
  name        = "golang-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 5000
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}
module "http_sg" {
  source      = "../../modules/security_group"
  name        = "http-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 80
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}
module "https_sg" {
  source      = "../../modules/security_group"
  name        = "https-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 443
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}
module "http_sg_public" {
  //外部から80ポートへのingressを許可(http)
  source      = "../../modules/security_group"
  name        = "http-sg-public"
  vpc_id      = data.aws_vpc.service.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
module "https_sg_public" {
  //外部から443ポートへのingressを許可(https)
  source      = "../../modules/security_group"
  name        = "https-sg-public"
  vpc_id      = data.aws_vpc.service.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}
module "ssh_sg" {
  source      = "../../modules/security_group"
  name        = "ssh-sg"
  vpc_id      = data.aws_vpc.service.id
  port        = 22
  cidr_blocks = [data.aws_vpc.service.cidr_block]
}