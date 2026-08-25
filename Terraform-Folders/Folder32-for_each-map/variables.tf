variable "security_groups" {
  description = "Map of security group names to their intended purpose."
  type        = map(string)
  default = {
    "sg-web"  = "allo http, https traffic"
    "sg-Admn" = "Access ssh access"
    "sg-db"   = "Allow MYSQL traffic"
  }

}
variable "instance_names" {
  type    = list(string)
  default = ["web-1", "web-3"]
}
variable "iam_id" {
  type    = string
  default = "ami-0b6d9d3d33ba97d99"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
