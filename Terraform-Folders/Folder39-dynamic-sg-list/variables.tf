variable "allowed_ports" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
  }))
   default = [
    { description = "SSH",   from_port = 22,  to_port = 22 },
    { description = "HTTP",  from_port = 80,  to_port = 80 },
    { description = "HTTPS", from_port = 443, to_port = 443 },
  ]
}