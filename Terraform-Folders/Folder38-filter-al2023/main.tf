# "Creates multiple EC2 instances based on the provided map of instance names."
resource "aws_instance" "server" {

  for_each      = var.aws_instance
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type
  tags = {
    Name = each.key
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami, instance_type, tags, ]
    prevent_destroy       = false
  }
}
