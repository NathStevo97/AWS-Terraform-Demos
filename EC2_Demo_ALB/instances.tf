resource "aws_instance" "app-server1" {
  instance_type          = "t2.micro"
  ami                    =  "ami-0c30afcb7ab02233d"
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  subnet_id              = aws_subnet.private-2a.id
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#associate_public_ip_address
  associate_public_ip_address = true
  tags = {
    Name = "app-server-1"
  }
  user_data = file("user_data/user_data.tpl")
}
resource "aws_instance" "app-server2" {
  instance_type               = "t2.micro"
  ami                         =  "ami-0c30afcb7ab02233d"
  vpc_security_group_ids      = [aws_security_group.http-sg.id]
  subnet_id                   = aws_subnet.private-2b.id
  associate_public_ip_address = true
  user_data                   = file("user_data/user_data.tpl")
  tags = {
    Name = "app-server-2"
  }
}
resource "aws_instance" "app-server3" {
  instance_type               = "t2.micro"
  ami                         =  "ami-0c30afcb7ab02233d"
  vpc_security_group_ids      = [aws_security_group.http-sg.id]
  subnet_id                   = aws_subnet.private-2c.id
  associate_public_ip_address = true
  user_data                   = file("user_data/user_data.tpl")
  tags = {
    Name = "app-server-3"
  }
}