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

 #  Create IGW
resource "aws_internet_gateway" "DemoIGW"{
    vpc_id = aws_vpc.demovpc.id
     tags = {
        Name = "DemoIGW"
    }
}

 #  Route Tables for public subnet
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
 
 #  Route table association public subnet A
resource "aws_route_table_association" "DemoPublicRTAssociationA"{
    subnet_id = aws_subnet.DemoPublicSubnetA.id
    route_table_id = aws_route_table.DemoPublicRT.id
}

#  Route table association public subnet B
resource "aws_route_table_association" "DemoPublicRTAssociationB"{
    subnet_id = aws_subnet.DemoPublicSubnetB.id
    route_table_id = aws_route_table.DemoPublicRT.id
}

#  Security group for Demo VPC
resource "aws_security_group" "demo_sg" {
  name        = "demo-security-group"
  description = "Demo security group"
  vpc_id = aws_vpc.demovpc.id
  
  tags = {
    Name = "Demo SG"
   }

  # Allow SSh
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostreSQL
  ingress {
    description = "Allow PostreSQL"
    from_port   = 5432
    to_port     = 5432
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

#   Create RDS subnet group (For Multi-AZ)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.DemoPublicSubnetA.id,
    aws_subnet.DemoPublicSubnetB.id
  ]

  tags = {
    Name = "RDS subnet group"
  }
}




