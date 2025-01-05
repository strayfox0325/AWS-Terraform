# Create VPC
resource "aws_vpc" "demovpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "DemoVPC"
    }
}

 # Create public subnet A
resource "aws_subnet" "DemoPublicSubnetA"{
    vpc_id = aws_vpc.demovpc.id
    availability_zone = "eu-central-1a"
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "DemoPublicSubnetA"
    }
}

 # Create public subnet B
resource "aws_subnet" "DemoPublicSubnetB"{
    vpc_id = aws_vpc.demovpc.id
    availability_zone = "eu-central-1b"
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "DemoPublicSubnetB"
    }
}

# Create private subnet A
resource "aws_subnet" "DemoPrivateSubnetA" {
  vpc_id            = aws_vpc.demovpc.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "DemoPrivateSubnetA"
  }
}

# Create private subnet B
resource "aws_subnet" "DemoPrivateSubnetB" {
  vpc_id            = aws_vpc.demovpc.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name = "DemoPrivateSubnetB"
  }
}

 #  Create IGW
resource "aws_internet_gateway" "DemoIGW"{
    vpc_id = aws_vpc.demovpc.id
     tags = {
        Name = "DemoIGW"
    }
}

# Create Elastic IP for NAT GW
resource "aws_eip" "DemoNAT" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "DemoNGW" {
  allocation_id = aws_eip.DemoNAT.id
  subnet_id     = aws_subnet.DemoPublicSubnetA.id

  tags = {
    Name = "Demo NAT Gateway"
  }
}

 # Create Route Tables for public subnet
resource "aws_route_table" "DemoPublicRT"{
    vpc_id = aws_vpc.demovpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.DemoIGW.id
    }
    tags = {
        Name = "DemoPublicRT"
    }
}

# Create Route Table for private subnets
resource "aws_route_table" "DemoPrivateRT" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.DemoNGW.id
  }

  tags = {
    Name = "DemoPrivateRT"
  }
}
 
 #  Route table association for public subnet A
resource "aws_route_table_association" "DemoPublicRTAssociationA"{
    subnet_id = aws_subnet.DemoPublicSubnetA.id
    route_table_id = aws_route_table.DemoPublicRT.id
}

#  Route table association for public subnet B
resource "aws_route_table_association" "DemoPublicRTAssociationB"{
    subnet_id = aws_subnet.DemoPublicSubnetB.id
    route_table_id = aws_route_table.DemoPublicRT.id
}

# Route Table association for private subnet A
resource "aws_route_table_association" "DemoPrivateRTAssociationA" {
  subnet_id      = aws_subnet.DemoPrivateSubnetA.id
  route_table_id = aws_route_table.DemoPrivateRT.id
}

# Route Table association for private subnet B
resource "aws_route_table_association" "DemoPrivateRTAssociationB" {
  subnet_id      = aws_subnet.DemoPrivateSubnetB.id
  route_table_id = aws_route_table.DemoPrivateRT.id
}

#  Security group for EC2 instance
resource "aws_security_group" "demo_sg" {
  name        = "demo-security-group"
  description = "Allow inbound and outbound traffic for EC2 instance"
  vpc_id = aws_vpc.demovpc.id
  
  tags = {
    Name = "demo-security-group"
  }

  # Allow inbound SSH
  ingress {
    description = "Allow inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP
  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


