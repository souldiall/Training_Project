resource "aws_instance" "web" {
  for_each      = toset(var.instance_names)
  ami           = var.iam_id
  instance_type = var.instance_type

  tags = {
    Name = each.key
  }

  lifecycle {
    prevent_destroy = false
  }
}
