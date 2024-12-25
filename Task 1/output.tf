output "instance_public_ip" {
  value = aws_instance.demo_ec2.public_ip
  description = "The public IP address of the instance"
}

output "rds_instance_endpoint" {
  value = aws_db_instance.postgresql.address
  description = "RDS instance ednpoint"
}