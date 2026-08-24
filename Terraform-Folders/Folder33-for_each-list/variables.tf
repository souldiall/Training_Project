variable "instance_names" {
  type    = list(string)
  default = ["web-1", "web-3"]
}
variable "iam_id" {
    type = string
  default =   "ami-0b6d9d3d33ba97d99" 
}
variable "instance_type" {
    type = string
    default = "t3.micro"
}