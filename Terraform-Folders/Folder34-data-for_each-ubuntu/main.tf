# -----------------------------
# 3. EC2 instances using for_each
# -----------------------------
resource "aws_instance" "server" {
  for_each = var.servers

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # same type for all instances

  tags = {
    Name = each.key
  }
}