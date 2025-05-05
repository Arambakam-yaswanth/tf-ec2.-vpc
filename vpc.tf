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

# lms public route table
resource "aws_route_table" "lms-pub-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms.id
  }

  tags = {
    Name = "lms-public-route"
  }
}

# lms private route table
resource "aws_route_table" "lms-pvt-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-private-route"
  }
}
# route-table-association 
resource "aws_route_table_association" "lms-web-asc" {
  subnet_id      = aws_subnet.lms-web-subnet.id
  route_table_id = aws_route_table.lms-pub-rt.id
}

# route-table-association 
resource "aws_route_table_association" "lms-api-asc" {
  subnet_id      = aws_subnet.lms-api-subnet.id
  route_table_id = aws_route_table.lms-pub-rt.id
}

# route-table-association 
resource "aws_route_table_association" "lms-db-asc" {
  subnet_id      = aws_subnet.lms-database-subnet.id
  route_table_id = aws_route_table.lms-pvt-rt.id
}