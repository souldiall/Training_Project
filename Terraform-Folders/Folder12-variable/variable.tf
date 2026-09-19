 variable "My_favorite_number" {
   type    = number
 }
 variable "name" {
   type    = string
   default = "soulDiallo"
 }

 variable "my_list" {
   type = list(string)
   default = [1, 2, 4, 8, 17, 25, 50, 100]
 }

 locals {
     my_odd_numbers = [for num in var.my_list : num if num % 2 != 0]
}



variable "my_number_of_instances" {}

variable "my_instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
}