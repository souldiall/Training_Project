# Folder27: Application Load Balancer with Path-Based HTML Responses

This example builds a small AWS web environment in `us-east-1`. It creates a VPC with two public subnets, two Apache web servers, an Application Load Balancer, target groups, and listener rules for `/app1` and `/app2`.

## What This Configuration Creates

- One VPC with CIDR `10.0.0.0/16`
- Two public subnets in `us-east-1a` and `us-east-1b`
- An internet gateway and public route table
- Security groups for the ALB and web instances
- Two Ubuntu EC2 instances running Apache
- Two target groups with HTTP health checks
- One internet-facing Application Load Balancer
- An HTTP listener on port 80
- `/app1` and `/app2` listener rules with HTML fixed responses
- An output containing the ALB DNS name

## Important Routing Note

The listener rules currently use `type = "fixed-response"`. Therefore, requests to `/app1` and `/app2` receive HTML directly from the ALB. They do not forward traffic to `app1_tg` or `app2_tg`, even though both target groups have EC2 instances attached.

The target groups and attachments are present for practice and health-check configuration. To route requests to the EC2 applications instead, replace each fixed-response action with a `forward` action targeting the corresponding target group.

## Architecture

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
   |
   +-- /app1 -> ALB fixed HTML response
   |
   +-- /app2 -> ALB fixed HTML response
   |
   +-- default -> "Welcome to app1 or app2"

VPC target groups and EC2 attachments are also created:
   app1 target group -> App1 EC2
   app2 target group -> App2 EC2
```

## Files

- `main.tf`: Defines the VPC, subnets, routing, security groups, ALB, listener, target groups, EC2 instances, and target attachments.
- `provider.tf`: Configures AWS in `us-east-1`.
- `variable.tf`: Defines the AMI ID and instance type.
- `output.tf`: Returns the ALB DNS name.
- `version.tf`: Defines Terraform and AWS provider version constraints.

## Prerequisites

- Terraform newer than `1.15`
- AWS provider version `6.5` or newer
- AWS credentials configured for the account
- Permissions to create VPC, subnet, route, security group, ALB, target group, and EC2 resources
- A valid Ubuntu AMI in `us-east-1`
- Sufficient EC2 and load-balancer quotas in `us-east-1`

The default AMI is configured for Ubuntu because the startup script uses `apt` and installs `apache2`. Replace it with an AMI compatible with that script if needed.

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Get the ALB address:

```bash
terraform output alb_dns_name
```

Test the listener paths:

```bash
curl http://$(terraform output -raw alb_dns_name)/app1
curl http://$(terraform output -raw alb_dns_name)/app2
```

The default listener response can be tested with:

```bash
curl http://$(terraform output -raw alb_dns_name)/
```

Remove all resources when finished:

```bash
terraform destroy
```

## Customizing Variables

The available variables are:

```hcl
ami_id       = "ami-valid-ubuntu-ami"
instance_type = "t3.micro"
```

You can place overrides in a `.tfvars` file or provide them on the command line:

```bash
terraform plan -var='instance_type=t3.micro'
```

## Security Considerations

The ALB allows HTTP traffic from `0.0.0.0/0`, which exposes the application to the internet. The web security group allows port 80 only from the ALB security group, which is a better pattern than exposing the instances directly.

The instances are assigned public IP addresses even though ALB traffic is intended to reach them through the web security group. In a production design, place the instances in private subnets, remove public IP assignment, and use controlled egress through a NAT gateway when required.

For production use, consider HTTPS with an ACM certificate, a port 443 listener, restricted administrative access, logging, monitoring, WAF protection, and deletion safeguards.

## Troubleshooting

### `InvalidAMIID.NotFound`

AMI IDs are region-specific. Confirm that `ami_id` exists in `us-east-1` and that it is an Ubuntu AMI compatible with the `apt` startup script.

### The ALB DNS name does not respond

Confirm that the ALB is active, both subnets are in different availability zones, the route table points to the internet gateway, and the ALB security group allows inbound TCP port 80.

### `/app1` or `/app2` returns the wrong content

Check the listener rule path patterns and priorities. The current rules match `/app1`, `/app1/*`, `/app2`, and `/app2/*`. The default listener response is used for other paths.

### Requests do not reach the EC2 instances

This is expected with the current `fixed-response` actions. To send traffic to the instances, change the listener rule action to `type = "forward"` and set the appropriate target group ARN.

### Target groups show unhealthy targets

Verify that Apache started successfully through `user_data`, the instances are listening on port 80, and the web security group allows port 80 from the ALB security group. Check the EC2 system log and the target health details in the EC2 console.

### Apache installation fails

The startup script uses `apt update` and `apt install apache2`, so it requires a Debian-based image with network access to package repositories. A different operating system needs a different startup script.

### `InsufficientInstanceCapacity` or quota errors

Try another instance type or availability zone, check EC2 service quotas, and verify that the AWS account can launch the requested number of instances.

### `DuplicateSecurityGroupName` or resource name conflicts

AWS resource names can conflict with existing resources in the same VPC or account. Rename the security groups, target groups, or ALB, or remove the previous resources from the correct Terraform state.

### Terraform prompts for a variable

Provide a value through a `.tfvars` file or with `-var`. For example:

```bash
terraform plan -var='ami_id=ami-valid-ubuntu-ami'
```

### Destroy fails

An ALB must have its listeners and target groups removed before the load balancer can be deleted. Let Terraform manage the dependency graph, and check for resources created outside this state if deletion is blocked.

## Lessons Learned

- An ALB needs subnets in at least two availability zones.
- Security groups can restrict backend traffic to requests originating from the ALB security group.
- Path-based listener rules match URL patterns and use priority to resolve rule order.
- A fixed response is different from forwarding traffic to a target group.
- Target health checks are essential when an ALB forwards requests to instances.
- User-data scripts must match the operating system and package manager of the selected AMI.
- Public subnets and internet-facing load balancers require deliberate network and security design.

## Conclusion

Folder27 demonstrates the main building blocks of an AWS Application Load Balancer environment: custom networking, public subnets, security groups, EC2 web servers, target groups, listener rules, and outputs. It also highlights the difference between returning content directly from an ALB and forwarding requests to backend instances. Before using this design in production, enable HTTPS, remove unnecessary public IPs, restrict network access, add observability, and choose intentionally between fixed responses and target-group forwarding.
