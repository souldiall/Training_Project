Folder38-filter-al2023
Terraform configuration for deploying three Amazon Linux 2023 EC2 instances using:

for_each with a map(string)

AMI filtering to dynamically fetch the latest al2023-ami

Clean, reusable infrastructure code

This project demonstrates how to create multiple EC2 instances using map keys as instance names.

 Project Overview
This Terraform project creates:

3 EC2 instances

Each instance name comes from a map(string)

AMI automatically retrieved using a filter for AL2023

Instances tagged using each.key

This avoids hard‑coding AMI IDs and makes your instance list fully configurable.

 Folder Structure
Code
Folder38-filter-al2023/
│
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
 AL2023 AMI Filtering
Amazon Linux 2023 AMIs follow the naming pattern:

Code
al2023-ami-*-x86_64
Terraform filter:# "Fetches the most recent Amazon Linux 2023 AMI ID based on specified filters."
data "aws_ami" "al2023" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "state"
    values = ["available"]

  }
  owners = ["amazon"]
}

hcl
data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}
This ensures your EC2 instances always use the latest AL2023 image.

 Instance Map (for_each)
Your instance list is defined as a map(string):

hcl
variable "instances" {
  type = map(string)
  default = {
    sserver1 = "first-instance"
    server2 = "second-instance"
    server3 = "third-instance"


  }
}
Keys = instance names
Values = instance types

 EC2 Instance Creation Using for_each
hcl
resource "aws_instance" "al2023_servers" {
  for_each      = var.instances
  ami           = data.aws_ami.al2023.id
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
This produces:

server1

server2

server3

All running Amazon Linux 2023.How to Deploy
1. Initialize Terraform
Code
terraform init
2. Validate
Code
terraform validate
3. Preview
Code
terraform plan
4. Deploy
Code
terraform applyDestroy Infrastructure
Code
terraform destroy
