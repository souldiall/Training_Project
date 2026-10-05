resource "aws_security_group" "sg_list" {
  name        = "my-sg-list"
  description = "SG using list"

  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
