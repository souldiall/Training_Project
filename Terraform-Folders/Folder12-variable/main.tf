# resource "aws_instance" "Instances" {
#   count         = var.my_number_of_instances
#   ami           = "something_random"
#   instance_type = "t3.micro"
# }

resource "aws_instance" "Instances" {
  for_each      = var.my_instances
  instance_type = each.value.instance_type
  ami           = each.value.ami
}