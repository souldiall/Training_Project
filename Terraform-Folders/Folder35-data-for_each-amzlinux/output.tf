
output "instance_ami_ids" {
  description = "AMI ID used by each EC2 instance"
  value = {
    for name, inst in aws_instance.instances :
    name => inst.ami
  }
}
