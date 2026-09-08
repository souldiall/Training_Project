variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The type of instance to create. Default is t3.micro."
}
variable "aws_instance" {
  description = "Map of instance names used to create multiple EC2 instances with unique tags."
  type        = map(string)
  default = {
    server1 = "first-instance"
    server2 = "second-instance"
    server3 = "third-instance"
  }
}