# -----------------------------
# 3. EC2 instances using for_each
# -----------------------------
resource "aws_instance" "instances" {
  for_each = var.instances

  ami           = data.aws_ami.amazLiunx.id
  instance_type = "t3.micro" # same type for all instances

  tags = {
    Name = each.key
  }
}