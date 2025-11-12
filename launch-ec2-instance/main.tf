terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "nextwork_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.resource_prefix} VPC"
  }
}

resource "aws_subnet" "nextwork_public_subnet_1" {
  vpc_id                  = aws_vpc.nextwork_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_prefix} Public Subnet"
  }
}

resource "aws_internet_gateway" "nextwork_ig" {
  vpc_id = aws_vpc.nextwork_vpc.id
  tags = {
    Name = "${var.resource_prefix} IG"
  }
}



resource "aws_default_route_table" "nextwork_vpc" {
  default_route_table_id = aws_vpc.nextwork_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nextwork_ig.id
  }

  tags = {
    Name = "${var.resource_prefix} Public Route table"
  }
}

resource "aws_route_table_association" "nextwork_public_subnet_1_association" {
  subnet_id      = aws_subnet.nextwork_public_subnet_1.id
  route_table_id = aws_default_route_table.nextwork_vpc.id
}

resource "aws_security_group" "nextwork_public_security_group" {
  name        = var.security_group_name
  vpc_id      = aws_vpc.nextwork_vpc.id
  description = "A Security Group for the ${var.resource_prefix} VPC Public Subnet"

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_from_anywhere" {
  security_group_id = aws_security_group.nextwork_public_security_group.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.http_port
  to_port           = var.http_port
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
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "${var.resource_prefix} Private Subnet"
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

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.nextwork_public_security_group.id]
  subnet_id                   = aws_subnet.nextwork_public_subnet_1.id
  associate_public_ip_address = true

  tags = {
    Name = "${var.resource_prefix} Public Server"
  }
}

resource "aws_security_group" "nextwork_private_security_group" {
  name        = "${var.resource_prefix} Private Security Group"
  vpc_id      = aws_vpc.nextwork_vpc.id
  description = "Security group for ${var.resource_prefix} Private Subnet"

  tags = {
    Name = "${var.resource_prefix} Private Security Group"
  }
}

resource "aws_instance" "nextwork_private_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.nextwork_private_security_group.id]
  subnet_id              = aws_subnet.network_private_subnet_1.id

  tags = {
    Name = "${var.resource_prefix} Private Server"
  }
}

resource "aws_security_group_rule" "allow_ssh_from_public_sg" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  security_group_id        = aws_security_group.nextwork_private_security_group.id
  source_security_group_id = aws_security_group.nextwork_public_security_group.id
}
