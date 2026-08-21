# This file defines resources for the Terraform configuration to create EC2 instances in two different AWS regions.
resource "aws_security_group" "east-web" {
  name        = "east-web"
  description = "Allow HTTP traffic to the east instance"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "west-web" {
  provider    = aws.west
  name        = "west-web"
  description = "Allow HTTP traffic to the west instance"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "east-instance" {
  region                      = var.region1
  ami                         = var.ami_id1 # Example AMI ID for us-east-1
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.east-web.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -eux
yum install -y httpd
systemctl enable --now httpd
echo "Hello from ${var.region1}" > /var/www/html/index.html
EOF

  tags = {
    Name = "EastInstance"
  }
}
resource "aws_instance" "west-instance" {
  provider = aws.west
  ami      = var.ami_id2 # Example AMI ID for us-west-2

  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.west-web.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -eux
yum install -y httpd
systemctl enable --now httpd
echo "Hello from ${var.region2}" > /var/www/html/index.html
EOF

  tags = {
    Name = "WestInstance"
  }
}
