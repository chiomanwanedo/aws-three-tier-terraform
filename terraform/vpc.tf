resource "aws_vpc" "three_tier_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "three-tier-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"

  tags = {
    Name = "three-tier-public-subnet-1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2b"

  tags = {
    Name = "three-tier-public-subnet-2"
  }
}


resource "aws_subnet" "private_app_subnet_1" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"

  tags = {
    Name = "three-tier-private-app-subnet-1"
  }
}



resource "aws_subnet" "private_app_subnet_2" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"

  tags = {
    Name = "three-tier-private-app-subnet-2"
  }
}


resource "aws_subnet" "private_data_subnet_1" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"

  tags = {
    Name = "three-tier-private-data-subnet-1"
  }
}



resource "aws_subnet" "private_data_subnet_2" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"

  tags = {
    Name = "three-tier-private-data-subnet-2"
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three-tier-internet-gateway"
  }
}