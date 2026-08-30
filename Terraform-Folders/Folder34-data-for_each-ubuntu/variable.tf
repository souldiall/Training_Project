# -----------------------------
# 1. Map of strings
# -----------------------------
variable "servers" {
  type = map(string)

  default = {
    web1 = "Hello"
    web2 = "World"
    api1 = "Test"
  }
}