resource "aws_instance" "web" {
  ami      = var.ami_id
  for_each = var.names
  instance_type = var.instance_type

  tags = {
    Name = each.key
  }
  lifecycle {
    prevent_destroy = false
  }
}