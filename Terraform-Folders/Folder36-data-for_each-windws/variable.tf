# -----------------------------
# 1. Map of strings
# -----------------------------
variable "servers" {
  type = map(string)

  default = {
    web1 = "Hello"
    web2 = "World"
    web3 = "Test"
  }
}
variable "instance_type"{
 type = string
 default = "t3.micro"
  
}
variable "region" {
  type = string
  default = "us-east-1"
}