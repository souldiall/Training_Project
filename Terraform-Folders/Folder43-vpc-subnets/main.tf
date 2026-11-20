resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo-VPC"
  }
}

resource "aws_subnet" "subnets" {
  count = 4

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 2, count.index)

  availability_zone = element(
    ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"],
    count.index
  )

  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}