# "Fetches the most recent Amazon Linux 2023 AMI ID based on specified filters."
data "aws_ami" "al2023" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "state"
    values = ["available"]

  }
  owners = ["amazon"]
}