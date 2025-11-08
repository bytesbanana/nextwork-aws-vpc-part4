provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "nextwork-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "NextWork VPC"
  }
}

resource "aws_subnet" "nextwork-public-subnet-1" {
  vpc_id                  = aws_vpc.nextwork-vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name : "Public 1"
  }
}

resource "aws_internet_gateway" "nextwork-ig" {
  vpc_id = aws_vpc.nextwork-vpc.id
  tags = {
    Name : "NextWork IG"
  }
}



resource "aws_default_route_table" "nextwork-vpc" {
  default_route_table_id = aws_vpc.nextwork-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextwork-ig.id
  }

  tags = {
    Name = "NextWork route table"
  }
}

resource "aws_route_table_association" "nextwork-public-subnet-1-association" {
  subnet_id      = aws_subnet.nextwork-public-subnet-1.id
  route_table_id = aws_default_route_table.nextwork-vpc.id
}
