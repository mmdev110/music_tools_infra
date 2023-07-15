//VPCは安定度の高い(?)Network側で定義しているが、
//NATゲートウェイ周りだけ課金が発生するため削除頻度の高いBackend側で定義

data "aws_vpc" "service" {
  tags = {
    service = module.constants.service_name
  }
}
data "aws_subnet" "public0" {
  tags = {
    service = module.constants.service_name
    Name    = "public0"
  }
}
data "aws_subnet" "public1" {
  tags = {
    service = module.constants.service_name
    Name    = "public1"
  }
}
data "aws_subnet" "web0" {
  tags = {
    service = module.constants.service_name
    Name    = "web0"
  }
}
data "aws_subnet" "web1" {
  tags = {
    service = module.constants.service_name
    Name    = "web1"
  }
}
data "aws_subnet" "db0" {
  tags = {
    service = module.constants.service_name
    Name    = "db0"
  }
}
data "aws_subnet" "db1" {
  tags = {
    service = module.constants.service_name
    Name    = "db1"
  }
}
data "aws_internet_gateway" "example" {
  tags = {
    service = module.constants.service_name
  }
}
data "aws_route_table" "private0" {
  tags = {
    service = module.constants.service_name
    Name    = "private0"
  }
}
data "aws_route_table" "private1" {
  tags = {
    service = module.constants.service_name
    Name    = "private1"
  }
}
//NATゲートウェイ
resource "aws_nat_gateway" "nat_gateway0" {
  allocation_id = aws_eip.nat_gateway0.id
  subnet_id     = data.aws_subnet.public0.id
  //depends_on    = [aws_internet_gateway.example]
}
resource "aws_route" "private0" {
  //外部アクセスをNATゲートウェイに飛ばす
  route_table_id         = data.aws_route_table.private0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway0.id
  destination_cidr_block = "0.0.0.0/0"
}
//NATゲートウェイにアタッチするEIP
resource "aws_eip" "nat_gateway0" {
  domain = "vpc"
  //depends_on = [aws_internet_gateway.example]
}
resource "aws_route" "private1" {
  //外部アクセスをNATゲートウェイに飛ばす
  //NATゲートウェイは1a側のを使いシングル構成とする(コスト都合)
  route_table_id         = data.aws_route_table.private1.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway0.id
  destination_cidr_block = "0.0.0.0/0"
}