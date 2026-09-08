# -----------------------------
# 1. Map of strings
# -----------------------------
variable "instances" {
  type = map(string)

  default = {
    web1 = "Hello"
    web2 = "World"
    web3 = "Test"
  }
}