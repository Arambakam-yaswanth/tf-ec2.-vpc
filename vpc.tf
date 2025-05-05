# vpc
resource "aws_vpc" "lms-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms-vpc"
  }
}

# web subnet
resource "aws_subnet" "lms-web-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch ="true"

  tags = {
    Name = "lms-web-subnet"
  }
}
# api subnet 
resource "aws_subnet" "lms-api-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch ="true"

  tags = {
    Name = "lms-api-subnet"
  }
}

# database subnet
resource "aws_subnet" "lms-database-subnet" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "lms-database-subnet"
  }
}
# internet-gateway
resource "aws_internet_gateway" "lms" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-internet_gateway"
  }
}
