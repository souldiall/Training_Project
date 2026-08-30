data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}
############################################
# Default VPC for the selected AWS region
############################################
data "aws_vpc" "default" {
  default = true
}
