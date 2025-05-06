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
# network-web-acl
resource "aws_network_acl" "lms-web-nacl" {
  vpc_id = aws_vpc.lms-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-web-nacl"
  }
}

# network-api-acl
resource "aws_network_acl" "lms-api-nacl" {
  vpc_id = aws_vpc.lms-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-api-nacl"
  }
}
# network-db-acl
resource "aws_network_acl" "lms-db-nacl" {
  vpc_id = aws_vpc.lms-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-db-nacl"
  }
}
# lms web nacl association
resource "aws_network_acl_association" "lms-web-nacl-asc" {
  network_acl_id = aws_network_acl.lms-web-nacl.id
  subnet_id      = aws_subnet.lms-web-subnet.id
}
# lms api nacl association
resource "aws_network_acl_association" "lms-api-nacl-asc" {
  network_acl_id = aws_network_acl.lms-api-nacl.id
  subnet_id      = aws_subnet.lms-api-subnet.id
}

# lms db nacl association
resource "aws_network_acl_association" "lms-db-nacl-asc" {
  network_acl_id = aws_network_acl.lms-db-nacl.id
  subnet_id      = aws_subnet.lms-database-subnet.id
}
# lms web security_group
resource "aws_security_group" "lms-web-sg" {
  name        = "lms-web-sg"
  description = "Allow SSH & HTTP traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-web-sg"
  }
}

# lms web security_group ingress
resource "aws_vpc_security_group_ingress_rule" "lms-web-sg-ingress-ssh" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "lms-web-sg-ingress-http" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# lms web security_group egress
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#lms api security_group
resource "aws_security_group" "lms-api-sg" {
  name        = "lms-api-sg"
  description = "Allow SSH & Nodejs traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-api-sg"
  }
}

# lms api security_group ingress
resource "aws_vpc_security_group_ingress_rule" "lms-api-sg-ingress-ssh" {
  security_group_id = aws_security_group.lms-api-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "lms-api-sg-ingress-nodejs" {
  security_group_id = aws_security_group.lms-api-sg.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# lms api security_group egress
resource "aws_vpc_security_group_egress_rule" "lms-api-sg-egress" {
  security_group_id = aws_security_group.lms-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}#
#db

#lms db security_group
resource "aws_security_group" "lms-db-sg" {
  name        = "lms-db-sg"
  description = "Allow SSH & postgres traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-db-sg"
  }
}

# lms db security_group ingress
resource "aws_vpc_security_group_ingress_rule" "lms-db-sg-ingress-ssh" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "lms-db-sg-ingress-postgres" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

# lms api security_group egress
resource "aws_vpc_security_group_egress_rule" "lms-db-sg-egress" {
  security_group_id = aws_security_group.lms-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}#
