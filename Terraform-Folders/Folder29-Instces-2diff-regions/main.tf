# This file defines resources for the Terraform configuration to create EC2 instances in two different AWS regions.
resource "aws_instance" "east-instance" {
  region        = var.region1
  ami           = var.ami_id1 # Example AMI ID for us-east-1
  instance_type = var.instance_type
  tags = {
    Name = "EastInstance"
  }
}
resource "aws_instance" "west-instance" {
  provider = aws.west
  ami      = var.ami_id2 # Example AMI ID for us-west-2

  instance_type = var.instance_type
  tags = {
    Name = "WestInstance"
  }
}