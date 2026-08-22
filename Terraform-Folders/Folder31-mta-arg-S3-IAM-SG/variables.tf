variable "buckets" {
  type = map(string)
  default = {
    "logs"    = "souldiallo-logs-us-east-1"
    "images"  = "souldiallo-images-us-east-1"
    "backups" = "souldiallo-backups-us-east-1"
  }
}
variable "iam_users" {
  type    = list(string)
  default = ["Mamadou", "Oumar", "Boubacar"]
}
variable "allowed_ports" {
  type    = list(number)
  default = [22, 80, 443]

}