resource "aws_vpc" "service" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "music-tools-backend"
    Env  = "prod"
  }
}
//IGW
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.service.id
}
//ルートテーブル自身
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.service.id
}
//private用ルートテーブル
resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.service.id
}
//ルートテーブルの1レコード
//外部へのアクセスをIGWに飛ばす
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

//パブリックサブネット1
resource "aws_subnet" "public0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
}
//ルートテーブルとサブネットの関連付け
resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id
}
//プライベートサブネット(web-1a)
resource "aws_subnet" "web0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.62.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}
//プライベートサブネット(db-1a)
resource "aws_subnet" "db0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.63.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}
resource "aws_route" "private0" {
  //外部アクセスをNATゲートウェイに飛ばす
  route_table_id         = aws_route_table.private0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway0.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "web0" {
  subnet_id      = aws_subnet.web0.id
  route_table_id = aws_route_table.private0.id
}
resource "aws_route_table_association" "db0" {
  subnet_id      = aws_subnet.db0.id
  route_table_id = aws_route_table.private0.id
}
//NATゲートウェイ
resource "aws_nat_gateway" "nat_gateway0" {
  allocation_id = aws_eip.nat_gateway0.id
  subnet_id     = aws_subnet.public0.id
  depends_on    = [aws_internet_gateway.example]
}
//NATゲートウェイにアタッチするEIP
resource "aws_eip" "nat_gateway0" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.example]
}