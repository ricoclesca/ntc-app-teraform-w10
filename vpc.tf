resource "aws_vpc" "My_vpc" {
  cidr_block           = "172.120.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = "ntc-vpc"
    environment = "dev"
    created_by  = "Max K"
    Team        = "wdp"
    app-name    = "ntc-app"

  }
}
// This is what makes the Vpc Public 
// Internet Gateway
resource "aws_internet_gateway" "My_igw" {
  vpc_id = aws_vpc.My_vpc.id

  tags = {
    Name = "ntc-igw"
  }

}

// Public Subnet Creation
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = "172.120.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ntc-public-sub1"
  }
  depends_on = [aws_vpc.My_vpc]
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.My_vpc.id
  cidr_block              = "172.120.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ntc-public-sub2"
  }
}
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.My_vpc.id
  cidr_block        = "172.120.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ntc-private1-sub1"
  }

}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.My_vpc.id
  cidr_block        = "172.120.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "ntc-private-sub2"
  }
}
//The Nat Gateway is used to connect the private subnet to the internet
// Nat Gateway 
resource "aws_eip" "eip" {

}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "ntc-NAT"
  }
}
// Route Table is the makes the differencies between a public and private subnet
// Code for Route Table => Private Subnet
resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.My_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
}
// Code for Route Table => Public Subnet
resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.My_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_igw.id
  }
}
// Route Table Association public Subnet
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id

}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}
// Route Table Association for private subnet
resource "aws_route_table_association" "rtaprivate1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}
resource "aws_route_table_association" "rtaprivate2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}