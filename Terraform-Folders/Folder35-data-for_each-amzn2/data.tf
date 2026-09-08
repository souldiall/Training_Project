# -----------------------------
# 2. Ubuntu AMI lookup
# -----------------------------
data "aws_ami" "amazLiunx" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}