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
    Name = "Demo EC2 Instance"
  }

  # Install PostgreSQL client
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable postgresql13
              sudo yum install -y postgresql

              echo "Testing connection to RDS PostgreSQL..."
              psql -h ${aws_db_instance.postgresql.endpoint} -U dbadmin -d demo_db -c "SELECT version();"
              EOF

  # Security group to allow SSH and HTTP access
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
}