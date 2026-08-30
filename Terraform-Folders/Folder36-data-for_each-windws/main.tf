# -----------------------------
# 3. EC2 instances using for_each
# -----------------------------
resource "aws_instance" "windows" {
  for_each = var.servers

  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type # same type for all instances

  tags = {
    Name = each.key
  }
}
resource "aws_security_group" "rdp" {
  name        = "rdp-access"
  description = "Allow RDP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
