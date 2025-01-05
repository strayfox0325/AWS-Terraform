#!/bin/bash

# Install PostgreSQL client
yum update -y
sudo amazon-linux-extras enable postgresql14
sudo yum install -y postgresql     

# Install Apache Web Server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create table
PGPASSWORD="Admin123." psql -h ${db_address} -U dbadmin -d demo_db <<SQL
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

SELECT * FROM employees;
SQL
