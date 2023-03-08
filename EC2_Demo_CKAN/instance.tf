resource "aws_instance" "default" {
  # ubuntu 18.04
  ami                         = "ami-033a08bfad4bde2dd" # This AMI is only available when subscribing to the Link Digital Image
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.default.id
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  key_name                    = "ckan-key-pair"

  tags = {
    Name = "CKAN-Demo"
  }

}

