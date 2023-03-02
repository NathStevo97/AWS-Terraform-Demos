resource "aws_subnet" "private-2a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    "Name" = "Application-1-private-2a"
  }
}
resource "aws_subnet" "private-2b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "Application-1-private-2b"
  }
}
resource "aws_subnet" "private-2c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.2.3.0/24"
  availability_zone = "eu-west-2c"
  tags = {
    "Name" = "Application-1-private-2c"
  }
}