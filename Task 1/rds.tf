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
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.demo_sg.id]

  tags = {
    Name = "Demo RDS instance"
  }
}