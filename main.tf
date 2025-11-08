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
