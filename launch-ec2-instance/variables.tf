variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "resource_prefix" {
  description = "Prefix to be used in resource names and tags"
  type        = string
  default     = "NextWork"
}

variable "security_group_name" {
  description = "Name of the public security group"
  type        = string
  default     = "NextWork Public Security Group"
}

variable "http_port" {
  description = "Port number for HTTP traffic"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.1.0/24"
}
