# Folder39 - Dynamic Security Group List

This Terraform project demonstrates how to create multiple ingress rules for an AWS security group using a `dynamic` block and a list of port objects.

## Purpose

The configuration defines a security group with several allowed inbound ports and uses a reusable variable to keep the rules easy to manage and extend.

## Files

- `main.tf` - creates the `aws_security_group` resource and defines the `dynamic "ingress"` block
- `variables.tf` - declares the `allowed_ports` variable with a list of objects
- `provider.tf` - configures the AWS provider for the `us-east-1` region
- `version.tf` - sets the Terraform and AWS provider version requirements

## Example variable

```hcl
allowed_ports = [
  { description = "SSH", from_port = 22, to_port = 22 },
  { description = "HTTP", from_port = 80, to_port = 80 },
  { description = "HTTPS", from_port = 443, to_port = 443 }
]
```

## What the infrastructure creates

- One AWS security group named `my-sg-list`
- Inbound rules for:
  - SSH on port 22
  - HTTP on port 80
  - HTTPS on port 443
- An outbound rule allowing all traffic (`0.0.0.0/0`)

## Usage

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Notes

This is a practical example of using `for_each` within a `dynamic` block to generate repeated ingress rules without writing each rule manually.
