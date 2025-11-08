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
    Name : "NextWork Public Subnet"
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
    Name = "NextWork Public Route table"
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

resource "aws_default_network_acl" "nextwork_public_subnet_1" {
  default_network_acl_id = aws_vpc.nextwork_vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "NextWork Public NACL"
  }
}

resource "aws_subnet" "network_private_subnet_1" {
  vpc_id     = aws_vpc.nextwork_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "NextWork Private Subnet"
  }
}

resource "aws_route_table" "network_private_route_table" {
  vpc_id = aws_vpc.nextwork_vpc.id

  tags = {
    Name = "NextWork Private Route Table"
  }
}

resource "aws_route_table_association" "network_private_subnet_1_association" {
  subnet_id      = aws_subnet.network_private_subnet_1.id
  route_table_id = aws_route_table.network_private_route_table.id
}

resource "aws_network_acl" "nextwork_private_subnet_NACL" {
  vpc_id     = aws_vpc.nextwork_vpc.id
  subnet_ids = [aws_subnet.network_private_subnet_1.id]

  tags = {
    Name = "NextWork Private NACL"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.20251105.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "nextwork-ec2-key"
  public_key = file("~/.ssh/id_rsa_nextwork_ec2.pub")
}

resource "aws_instance" "nextwork_public_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.nextwork_public_security_group.id]
  subnet_id                   = aws_subnet.nextwork_public_subnet_1.id
  associate_public_ip_address = true


  tags = {
    Name = "NextWork Public Server"
  }
}
