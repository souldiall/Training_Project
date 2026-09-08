output "public_ip" {
  value       = { for key, instance in aws_instance.server : key => instance.public_ip }
  description = "Map of public IP addresses for the created EC2 instances."
}