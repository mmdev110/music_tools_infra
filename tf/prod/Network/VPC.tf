resource "aws_vpc" "service" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "music_tools_backend"
  }
}
//IGW
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.service.id
}
//ap-northeast-1aについて
//パブリックサブネット0
resource "aws_subnet" "public0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "public0"
  }
}
//プライベートサブネット(web-1a)
resource "aws_subnet" "web0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.62.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "web0"
  }
}
//プライベートサブネット(db-1a)
resource "aws_subnet" "db0" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.63.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "db0"
  }
}
//ルートテーブル: aws_route_table
//ルートテーブルのレコード: aws_route
//ルートテーブルとサブネットの紐付け: aws_route_table_association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.service.id
}
resource "aws_route" "public" {
  //外部へのアクセスをIGWに飛ばす
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}
//ルートテーブルとサブネットの紐付け
resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.service.id
  tags = {
    Name = "private0"
  }
}
resource "aws_route_table_association" "web0" {
  subnet_id      = aws_subnet.web0.id
  route_table_id = aws_route_table.private0.id
}
resource "aws_route_table_association" "db0" {
  subnet_id      = aws_subnet.db0.id
  route_table_id = aws_route_table.private0.id
}
//ap-northeast-1cについて
//パブリックサブネット1
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "public1"
  }
}
//ルートテーブルとサブネットの紐付け
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
//プライベートサブネット(web-1c)
resource "aws_subnet" "web1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.64.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "web1"
  }
}
//プライベートサブネット(db-1c)
resource "aws_subnet" "db1" {
  vpc_id                  = aws_vpc.service.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "db1"
  }
}
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.service.id
  tags = {
    Name = "private1"
  }
}
resource "aws_route_table_association" "web1" {
  subnet_id      = aws_subnet.web1.id
  route_table_id = aws_route_table.private1.id
}
resource "aws_route_table_association" "db1" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.private1.id
}
