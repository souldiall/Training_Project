# This file defines variables for the Terraform configuration to create EC2 instances in two different AWS regions.
variable "ami_id1" {
  default     = "ami-0332d564d76dbd8d6"
  type        = string
  description = "The AMI ID to use for the us-east-1 EC2 instance"
}
variable "ami_id2" {
  default     = "ami-08b7b9fdd7a1edf3d"
  type        = string
  description = "The AMI ID to use for the us-west-2 EC2 instance"
}

variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "The instance type to use for us-east-1 and us-west-2 EC2 instances"
}
variable "region1" {
  default     = "us-east-1"
  type        = string
  description = "The AWS us-east-1 region to deploy the EC2 instance"
}
variable "region2" {
  default     = "us-west-2"
  type        = string
  description = "The AWS us-west-2 region to deploy the EC2 instance"
}