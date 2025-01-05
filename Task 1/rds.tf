resource "aws_db_subnet_group" "rds_private_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = [
    aws_subnet.DemoPrivateSubnetA.id,
    aws_subnet.DemoPrivateSubnetB.id
  ]

  tags = {
    Name = "RDS Private Subnet Group"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow outbound traffic to EC2 from RDS"
  vpc_id      = aws_vpc.demovpc.id

  tags = {
    Name = "ec2-security-group"
  }
}

#  Security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound traffic to RDS from EC2"
  vpc_id = aws_vpc.demovpc.id
  
  tags = {
    Name = "rds-security-group"
  }
}

# Allow inbound traffic from EC2 to RDS instance
resource "aws_security_group_rule" "from_ec2_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

# Allow outbound traffic from RDS to RDS EC2 instance 
resource "aws_security_group_rule" "from_rds_to_ec2" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
}

resource "aws_db_instance" "postgresql" {
  identifier              = "demo-rds"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "demo_db"
  username                = "dbadmin"
  password                = "Admin123."
  multi_az                = true
  publicly_accessible     = false
  backup_retention_period = 14
  db_subnet_group_name    = aws_db_subnet_group.rds_private_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  tags = {
    Name = "Demo RDS instance"
  }
}