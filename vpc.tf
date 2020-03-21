#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo-conjur" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   =  true
  enable_dns_hostnames =  false

  tags = {
     Name= "${var.client_name}-${var.product}-${var.environment}-${var.region}-vpc",
     test= "test" 
  }
}

resource "aws_subnet" "demo-conjur" {
  
  cidr_block        = var.subnet
  map_public_ip_on_launch = true
  vpc_id            = aws_vpc.demo-conjur.id

  tags = {
     Name= "${var.client_name}-${var.product}-${var.environment}-${var.region}-subn",
     test= "test"
  }
}

resource "aws_internet_gateway" "demo-conjur" {
  vpc_id = aws_vpc.demo-conjur.id

  tags = {
    Name = "${var.client_name}-${var.product}-${var.environment}-${var.region}"
  }
}

resource "aws_route_table" "demo-conjur" {
  vpc_id = aws_vpc.demo-conjur.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-conjur.id
  }
}

resource "aws_route_table_association" "demo-conjur" {

  subnet_id      = aws_subnet.demo-conjur.id
  route_table_id = aws_route_table.demo-conjur.id
}
