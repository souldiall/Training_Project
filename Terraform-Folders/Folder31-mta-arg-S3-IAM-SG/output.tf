output "ports_string" {
  value = join(", ", [for p in var.allowed_ports : tostring(p)])
}