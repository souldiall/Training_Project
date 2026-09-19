# Folder29: EC2 Instances in Two AWS Regions

This example creates two Amazon EC2 instances in different AWS regions. One instance is deployed in `us-east-1` and the other in `us-west-2`. Each instance receives its own security group and installs Apache HTTP Server through `user_data`.

## What This Configuration Creates

- One EC2 instance in `us-east-1`
- One EC2 instance in `us-west-2`
- One security group per region
- HTTP ingress on port 80 for each instance
- Open outbound traffic for each security group
- Apache installed and started automatically with `user_data`
- Public IP outputs for both instances

The default instance type is `t3.micro`.

## Files

- `main.tf`: Defines the regional security groups and EC2 instances.
- `providr.tf`: Defines the default AWS provider in `us-east-1` and the `west` provider alias in `us-west-2`.
- `variable.tf`: Defines AMI IDs, regions, and instance type.
- `output.tf`: Displays the public IP address of each instance.
- `version.tf`: Defines Terraform and AWS provider version constraints.

The filename `providr.tf` is intentional in this folder, but Terraform loads it because it has the `.tf` extension.

## Regional Provider Configuration

The default provider targets `us-east-1`. The aliased provider targets `us-west-2`:

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

The west security group and west instance explicitly use `provider = aws.west`. The east resources use the default provider.

## Prerequisites

- Terraform `>= 1.15`
- AWS provider `>= 6.5`
- AWS credentials configured for the account
- Permission to create EC2 instances, security groups, and related networking resources
- A valid AMI in each target region
- A default VPC and subnet available in both regions, unless the configuration is extended with explicit VPC and subnet settings

AMI IDs are regional. The value for `ami_id1` must exist in `us-east-1`, and the value for `ami_id2` must exist in `us-west-2`.

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After applying, display the instance public IPs:

```bash
terraform output public_ip_east
terraform output public_ip_west
```

To test the web servers, open each returned IP address in a browser or use:

```bash
curl http://<public-ip>
```

To remove the resources:

```bash
terraform destroy
```

## Customizing Variables

Override the defaults in a `.tfvars` file or on the command line:

```hcl
ami_id1      = "ami-valid-in-us-east-1"
ami_id2      = "ami-valid-in-us-west-2"
instance_type = "t3.micro"
region1      = "us-east-1"
region2      = "us-west-2"
```

Use AMI IDs that match the operating system and architecture expected by the startup script. The script currently uses `yum`, so the AMIs should be compatible with RPM-based distributions such as Amazon Linux.

## Security Considerations

The security groups allow HTTP from `0.0.0.0/0`, which makes port 80 reachable from the internet. Restrict the CIDR range when the service should be private or accessible only from a known network.

The configuration does not allow SSH, so remote administration through port 22 is not available by default. If SSH is added, restrict it to a trusted IP range and configure a key pair rather than opening it globally.

For production use, consider private subnets, an application load balancer, HTTPS, IAM roles, monitoring, encrypted volumes, and explicit VPC and subnet selection.

## Troubleshooting

### `InvalidAMIID.NotFound`

AMI IDs are region-specific. Verify that `ami_id1` exists in `us-east-1` and `ami_id2` exists in `us-west-2`. Use the AWS CLI or EC2 console in the correct region to find a compatible AMI.

### `UnauthorizedOperation` or `AccessDenied`

Confirm that the active AWS identity can create EC2 instances and security groups in both regions. Organization policies, quotas, or region restrictions may also block the operation.

### The instance fails during startup

Inspect the instance system log. The startup script installs Apache with `yum`, so a non-RPM AMI or an AMI without the expected package manager will fail. Also verify that the instance can reach package repositories.

### The public IP is empty

The instance may not have been assigned a public IPv4 address, or the subnet may not auto-assign public IPs. Check the subnet and VPC configuration, and consider setting `associate_public_ip_address = true` or managing the subnet explicitly.

### The web page cannot be reached

Confirm that the instance is running, the security group allows TCP port 80, the subnet route table has internet access, and the instance has a public IP. The Apache service must also be running successfully.

### A provider alias error appears

Verify that `providr.tf` contains the `west` alias and that the west resources use `provider = aws.west`. Run `terraform init` after changing provider configuration.

### The requested instance type is unavailable

Instance types differ by region, availability zone, account limits, and architecture. Choose a type supported by the selected AMI and available in the target region.

### Terraform prompts for a variable

Supply the variable through a `.tfvars` file or with `-var`. For example:

```bash
terraform plan -var='instance_type=t3.micro'
```

### Destroy fails

Check whether other resources depend on the security groups or instances. Confirm that the active credentials have deletion permissions and review the Terraform plan before retrying.

## Lessons Learned

- Provider aliases allow one Terraform configuration to manage resources in multiple AWS regions.
- AMI IDs must be selected separately for each region.
- Security groups are regional and must be associated with resources in the same region.
- `user_data` is useful for repeatable first-boot configuration, but scripts should match the operating system in the selected AMI.
- Public IP outputs make regional instances easy to test after deployment.
- Internet-facing rules should be limited to the smallest practical CIDR range.

## Conclusion

Folder29 demonstrates how Terraform can deploy similar EC2 workloads across two AWS regions using provider aliases, region-specific AMIs, independent security groups, startup scripts, and outputs. It is a useful foundation for multi-region practice. Before using this pattern in production, add explicit networking, tighten inbound access, use secure administration methods, validate AMI compatibility, and add monitoring and HTTPS.
