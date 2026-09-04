resource "aws_instance" "az_instances" {
  for_each = toset(data.aws_ec2_instance_type_offerings.supported.locations)

  ami               = data.aws_ami.latest.id
  instance_type     = var.instance_type
  availability_zone = each.key
  user_data         = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable --now httpd

    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
      <head>
        <title>Application from server</title>
      </head>
      <body>
        <h1>Application from server in AZ: ${each.key}</h1>
      </body>
    </html>
    HTML
  EOF
  tags = {
    Name = "instance-${each.key}"
  }
}

