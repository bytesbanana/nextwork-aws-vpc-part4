provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "nextwork_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "NextWork VPC"
  }
}

resource "aws_subnet" "nextwork_public_subnet_1" {
  vpc_id                  = aws_vpc.nextwork_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name : "Public 1"
  }
}

resource "aws_internet_gateway" "nextwork_ig" {
  vpc_id = aws_vpc.nextwork_vpc.id
  tags = {
    Name : "NextWork IG"
  }
}



resource "aws_default_route_table" "nextwork_vpc" {
  default_route_table_id = aws_vpc.nextwork_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextwork_ig.id
  }

  tags = {
    Name = "NextWork route table"
  }
}

resource "aws_route_table_association" "nextwork_public_subnet_1_association" {
  subnet_id      = aws_subnet.nextwork_public_subnet_1.id
  route_table_id = aws_default_route_table.nextwork_vpc.id
}

resource "aws_security_group" "nextwork_public_security_group" {
  name        = "NextWork Public Security Group"
  vpc_id      = aws_vpc.nextwork_vpc.id
  description = "A Security Group for the NextWork VPC Public Subnet"

  tags = {
    Name = "NextWork Public Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_from_anywhere" {
  security_group_id = aws_security_group.nextwork_public_security_group.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}
