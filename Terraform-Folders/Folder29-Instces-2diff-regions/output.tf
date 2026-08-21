#
output "public_ip_east" {
  value       = aws_instance.east-instance.public_ip
  description = "The public IP address of the EC2 instance in us-east-1"

}
output "public_ip_west" {
  value       = aws_instance.west-instance.public_ip
  description = "The public IP address of the EC2 instance in us-west-2"
}