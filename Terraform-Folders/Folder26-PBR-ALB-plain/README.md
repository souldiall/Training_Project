# Folder26: Application Load Balancer with Plain-Text Path Routing

This example demonstrates path-based routing with an AWS Application Load Balancer in `us-east-1`. It creates a custom VPC, two public subnets, two Apache EC2 instances, two target groups, and listener rules for `/app1` and `/app2`.

## What This Configuration Creates

- One VPC with CIDR `10.0.0.0/16`
- Two public subnets in `us-east-1a` and `us-east-1b`
- An internet gateway and public route table
- Security groups for the ALB and backend instances
- Two EC2 instances running Apache
- Two HTTP target groups with health checks
- One internet-facing Application Load Balancer
- One HTTP listener on port 80
- Plain-text listener responses for `/app1` and `/app2`
- An output containing the ALB DNS name

## Important Routing Note

The listener rules use `type = "fixed-response"`. Requests to `/app1` return `Welcome to App1`, and requests to `/app2` return `Welcome to App2` directly from the ALB. The listener does not forward those requests to the target groups.

The target groups and EC2 attachments are still created, but they are not used by the current listener rules. To route requests to the EC2 instances, replace each fixed response with a forward action that references the matching target group.

## Architecture

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
   |
   +-- /app1 -> "Welcome to App1"
   |
   +-- /app2 -> "Welcome to App2"
   |
   +-- other paths -> "Welcome to app1 or app2"

Target groups and EC2 instances are created separately:
   app1 target group -> App1 EC2
   app2 target group -> App2 EC2
```

## Files

- `main.tf`: Defines the VPC, networking, security groups, ALB, listener rules, target groups, EC2 instances, and attachments.
- `variable.tf`: Defines the AMI ID and instance type.
- `output.tf`: Returns the ALB DNS name.

This folder currently does not include a `provider.tf` or `version.tf` file. Add provider configuration and version constraints before treating this folder as a standalone Terraform project.

## Prerequisites

- Terraform installed
- AWS provider configuration for `us-east-1`
- AWS credentials configured for the account
- Permissions to create VPC, subnet, route, security group, ALB, target group, and EC2 resources
- A valid AMI in `us-east-1`
- Sufficient EC2 and load-balancer quotas

The default AMI is expected to support `yum` and `httpd`, such as a compatible Amazon Linux image. Replace `ami_id` when using a different image or region.

## Example Provider Configuration

A standalone configuration needs an AWS provider, for example:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

## Usage

From this directory, after adding provider configuration if needed:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Get the ALB DNS name:

```bash
terraform output -raw alb_dns
```

Test the listener paths:

```bash
curl http://$(terraform output -raw alb_dns)/app1
curl http://$(terraform output -raw alb_dns)/app2
curl http://$(terraform output -raw alb_dns)/
```

Remove the created resources when finished:

```bash
terraform destroy
```

## Customizing Variables

Override the variables in a `.tfvars` file or on the command line:

```hcl
ami_id       = "ami-valid-in-us-east-1"
instance_type = "t3.micro"
```

For example:

```bash
terraform plan -var='instance_type=t3.micro'
```

The AMI must exist in the selected region and must support the startup commands in `user_data`:

```bash
yum update -y
yum install -y httpd
```

## Security Considerations

The ALB accepts HTTP traffic from `0.0.0.0/0`. The backend security group allows port 80 only from the ALB security group, which prevents direct HTTP access through the configured security group.

The EC2 instances receive public IP addresses and are placed in public subnets. For production, use private subnets for backend instances, remove unnecessary public IPs, add HTTPS with an ACM certificate, and restrict administrative access.

The example allows all outbound traffic. Review egress requirements before using this design in a production environment.

## Troubleshooting

### Terraform cannot initialize the folder

Confirm that the folder contains an AWS provider configuration. This folder currently has no `provider.tf` or `version.tf`, so add those files or run it together with a parent configuration that supplies the provider.

### `InvalidAMIID.NotFound`

AMI IDs are region-specific. Verify that `ami_id` exists in `us-east-1` and that it is compatible with the `yum` and `httpd` startup commands.

### The ALB DNS name does not respond

Check that the ALB is active, the two subnets are in different availability zones, the route table points to the internet gateway, and the ALB security group allows inbound TCP port 80.

### `/app1` or `/app2` returns unexpected content

Check the listener rule path patterns and priorities. The current rules match `/app1`, `/app1/*`, `/app2`, and `/app2/*`. Other paths use the default fixed response.

### Requests do not reach the EC2 instances

This is expected with the current fixed-response actions. To use the backend instances, change the listener rules to forward to `aws_lb_target_group.app1_tg` and `aws_lb_target_group.app2_tg` respectively.

### Target groups show unhealthy targets

Confirm that Apache started successfully, the instances listen on port 80, and the backend security group allows HTTP from the ALB security group. Review EC2 system logs and target health details.

### Apache installation fails

The startup script requires an RPM-based image with `yum`. Use a compatible Amazon Linux AMI or change the script to use the package manager for the selected operating system.

### `AccessDenied` or quota errors

Verify AWS permissions for all created services and check EC2, VPC, and load-balancer service quotas in `us-east-1`.

### Security group or ALB name conflicts

Names such as `alb-sg`, `web-sg`, and `path-routing-alb` may conflict with resources already present in the account or VPC. Rename them or remove the old resources from the correct Terraform state.

### Destroy fails

Review the Terraform plan and state. Confirm that the credentials have delete permissions and that no resources outside this configuration depend on the VPC, subnets, security groups, or load balancer.

## Lessons Learned

- ALB listener rules can match URL paths and return fixed responses without backend application traffic.
- A target group attachment alone does not make a listener forward requests to an instance.
- Backend security groups can allow traffic from the ALB security group rather than from the whole internet.
- ALBs require subnets in at least two availability zones.
- User-data scripts must match the operating system and package manager of the selected AMI.
- Provider and version files are essential when a Terraform folder is intended to run independently.

## Conclusion

Folder26 is a focused demonstration of ALB path-based routing with plain-text fixed responses. It also creates the networking and backend resources needed for a more complete load-balancing design, making the difference between listener responses and target-group forwarding easy to study. Before using this configuration in production, add provider constraints, enable HTTPS, protect backend instances in private subnets, restrict access, and decide explicitly whether each path should return a fixed response or reach an application target.
