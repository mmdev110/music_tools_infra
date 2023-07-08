resource "aws_vpc" "service" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "music-tools-backend"
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
//パブリックサブネット2
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
}
//ルートテーブルとサブネットの関連付け
resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
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
//プライベートサブネット(web-1c)
resource "aws_subnet" "web1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.66.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}
//プライベートサブネット(db-1c)
resource "aws_subnet" "db1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.67.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}
//private用ルートテーブル
resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.service.id
}
resource "aws_route" "private0" {
  //外部アクセスをNATゲートウェイに飛ばす
  route_table_id         = aws_route_table.private0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway0.id
  destination_cidr_block = "0.0.0.0/0"
}
//private用ルートテーブル2
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.service.id
}
resource "aws_route" "private1" {
  //外部アクセスをNATゲートウェイに飛ばす
  route_table_id         = aws_route_table.private1.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id
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
resource "aws_route_table_association" "web1" {
  subnet_id      = aws_subnet.web1.id
  route_table_id = aws_route_table.private1.id
}
resource "aws_route_table_association" "db1" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.private1.id
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
//NATゲートウェイ2つ目
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_gateway1.id
  subnet_id     = aws_subnet.public1.id
  depends_on    = [aws_internet_gateway.example]
}
//NATゲートウェイにアタッチするEIP
resource "aws_eip" "nat_gateway1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.example]
}