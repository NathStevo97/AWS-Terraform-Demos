resource "aws_route_table" "this-rt" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "Application-1-route-table"
  }
}
resource "aws_route_table_association" "private-2a" {
  subnet_id      = aws_subnet.private-2a.id
  route_table_id = aws_route_table.this-rt.id
}
resource "aws_route_table_association" "private-2b" {
  subnet_id      = aws_subnet.private-2b.id
  route_table_id = aws_route_table.this-rt.id
}
resource "aws_route_table_association" "private-2c" {
  subnet_id      = aws_subnet.private-2c.id
  route_table_id = aws_route_table.this-rt.id
}

resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.this-rt.id
  gateway_id             = aws_internet_gateway.this-igw.id
}