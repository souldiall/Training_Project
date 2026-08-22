resource "aws_s3_bucket" "Myfirst" {
    lifecycle {
      prevent_destroy = false
    }
  for_each = var.buckets

  bucket = each.value
}
resource "aws_iam_user" "users" {
    lifecycle {
      prevent_destroy = false
      
    }
    depends_on = [ aws_s3_bucket.Myfirst ]
  count = length(var.iam_users)
  name  = var.iam_users[count.index]
}
resource "aws_security_group" "web-sg" {
    lifecycle {
      prevent_destroy = false
    }
    depends_on = [ aws_iam_user.users ]
  description = "Allowed web traffic"
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}