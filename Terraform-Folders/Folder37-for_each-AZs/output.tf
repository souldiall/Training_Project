# Map of AZ → Public IP
output "public_ips" {
  description = "Public IPs of EC2 instances mapped by AZ"
  value = {
    for az, inst in aws_instance.az_instances :
    az => inst.public_ip
  }
}
