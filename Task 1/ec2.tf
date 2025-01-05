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
    filename = "demo-key.pem"
    file_permission = "0400"
}

#   Create EC2 instance
resource "aws_instance" "demo_ec2" {
  ami           = "ami-071f0796b00a3a89d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.demo_key_pair.key_name
  subnet_id     = aws_subnet.DemoPublicSubnetA.id
  security_groups = [aws_security_group.demo_sg.id, aws_security_group.ec2_sg.id]
  
  # Reference user_data script
  user_data = templatefile("user_data.sh", {
    db_address = aws_db_instance.postgresql.address
  })

  tags = {
    Name = "Demo EC2 Instance"
    Description = "Test instance"
    CostCenter  = "123456"
  }
}