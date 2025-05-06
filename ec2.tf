# EC2 web server
resource "aws_instance" "lms-web-server" {
  ami           = "ami-075686beab831bb7f"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.lms-web-subnet.id
  key_name = "Oregon"
vpc_security_group_ids = [aws_security_group.lms-web-sg.id]
user_data = file("setup.sh")
 tags = {
    Name = "lms-web-server"
  }
}

