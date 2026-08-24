variable "names" {
  type = map(string)
  default = {
    "Instance1" = "yelow"
    "Instance2" = "green"
    "Instance3" = "blue"
    "instance0" = "black"
  }
}

variable "ami_id" {
  type    = string
  default = "ami-0b6d9d3d33ba97d99"
}
variable "instance_type" {
  default = "t3.micro"
}