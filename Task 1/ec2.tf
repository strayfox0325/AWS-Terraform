#   Create private key (PEM)
resource "tls_private_key" "demo_private_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

#   Create key pair   
resource "aws_key_pair" "demo_key_pair" {
    key_name = "demo-key"
    public_key = tls_private_key.demo_private_key.public_key_openssh
}

#   Save private key to local machine
resource "local_file" "demo_private_key" {
    content = tls_private_key.demo_private_key.private_key_pem
    filename = "demo-key"
}

#   Create EC2 instance
resource "aws_instance" "demo_ec2" {
  ami           = "ami-071f0796b00a3a89d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.demo_key_pair.key_name
  subnet_id     = aws_subnet.DemoPublicSubnetA.id    
  
  tags = {
    Name        = "test-ec2"
    Description = "Test instance"
    CostCenter  = "123456"
  }

  # Install PostgreSQL client
  # psql -h demo-rds.cdkog0wmkozq.eu-central-1.rds.amazonaws.com -U dbadmin -d demo_db
  user_data = <<-EOF
              #!/bin/bash

              # Install PostreSQL
              sudo yum update -y
              sudo amazon-linux-extras enable postgresql13
              sudo yum install -y postgresql

              echo "Testing connection to RDS PostgreSQL..."
              psql -h ${aws_db_instance.postgresql.address} -U dbadmin -d demo_db -c "SELECT version();"

              # Create table
              PGPASSWORD="Admin123." psql -h ${aws_db_instance.postgresql.address} -U dbadmin -d demo_db <<SQL
              CREATE TABLE employees (
                id SERIAL PRIMARY KEY,
                first_name VARCHAR(20),
                last_name VARCHAR(20),
                email VARCHAR(50),
                position VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
              );

              INSERT INTO employees (first_name, last_name, email, position) VALUES
              ('Ana', 'Markovic', 'anam@company.com', 'HR Manager'),
              ('Dejan', 'Simic', 'dejans@company.com', 'Cloud Engineer'),
              ('Nikola', 'Tosic', 'nikola@company.com', 'Database Administrator');
              SQL

              # Instalacija i startovanje Apache Web Servera
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  # Security group to allow SSH and HTTP access
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
}

# Create and assign Elastic IP
resource "aws_eip" "demo_eip" {
  instance = aws_instance.demo_ec2.id
  tags = {
    Name = "Demo Elastic IP"
  }
}