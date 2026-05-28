resource "aws_route_table" "public_route_table" {
  vpc_id     = aws_vpc.three_tier_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
    
  tags = {
    Name = "three-tier-public-route-table"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id     = aws_vpc.three_tier_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }
    
  tags = {
    Name = "three-tier-private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id

}




resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}



resource "aws_route_table_association" "private_app_subnet_1_association" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}





resource "aws_route_table_association" "private_app_subnet_2_association" {
  subnet_id      = aws_subnet.private_app_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}



resource "aws_route_table_association" "private_data_subnet_1_association" {
  subnet_id      = aws_subnet.private_data_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_route_table_association" "private_data_subnet_2_association" {
  subnet_id      = aws_subnet.private_data_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}



