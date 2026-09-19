# Folder36: Windows EC2 Instances with `for_each`

This Terraform example creates multiple Windows EC2 instances from a map and dynamically selects the latest Amazon-owned Windows Server 2025 base AMI. It also discovers the default VPC and defines a security group intended for RDP access.

## What This Configuration Creates

With the default values, Terraform creates:

- Three Windows EC2 instances: `web1`, `web2`, and `web3`
- One RDP security group named `rdp-access` in the default VPC
- An output mapping each instance name to the AMI ID used

All instances use the shared `t3.micro` instance type and the AMI returned by the Windows AMI data source.

## Important Implementation Note

The `aws_security_group.rdp` resource is currently defined but is not attached to `aws_instance.windows`. The EC2 resource does not set `vpc_security_group_ids`, so the security group does not control the created instances as written.

Before relying on RDP access, attach the group explicitly, for example:

```hcl
resource "aws_instance" "windows" {
  # ...
  vpc_security_group_ids = [aws_security_group.rdp.id]
}
```

Review this change carefully before applying it to existing instances.

## Windows AMI Selection

The `aws_ami.windows` data source selects the most recent Amazon-owned image matching:

```text
Windows_Server-2025-English-Full-Base-*
```

AMI IDs are regional, so the selected image can differ when `var.region` changes. The image should be compatible with the selected instance type and account architecture.

## Files

- `main.tf`: Creates the Windows instances and the RDP security group.
- `data.tf`: Finds the latest Windows Server 2025 AMI and the default VPC.
- `variable.tf`: Defines the server map, instance type, and AWS region.
- `provider.tf`: Configures AWS with the selected region.
- `output.tf`: Returns the AMI ID used by each instance.
- `version.tf`: Defines Terraform and AWS provider version constraints.

## `for_each` Behavior

The instances use:

```hcl
for_each = var.servers
```

The map keys become Terraform resource addresses and instance `Name` tags:

```text
aws_instance.windows["web1"]
aws_instance.windows["web2"]
aws_instance.windows["web3"]
```

The current map values (`Hello`, `World`, and `Test`) are not used by `main.tf`; they are descriptive values only. The `instance_type` variable controls all instances.

## Prerequisites

- Terraform `>= 1.15`
- AWS provider `>= 6.50`
- AWS credentials configured for the target account
- Permission to describe AMIs and VPCs and create EC2 instances and security groups
- A default VPC in the selected region
- A Windows Server 2025 AMI available in the selected region
- Sufficient EC2 quota

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Display the AMI IDs used by the instances:

```bash
terraform output instance_ami_ids
```

Destroy the resources when finished:

```bash
terraform destroy
```

## Customizing Variables

Override the region, instance type, or server map in a `.tfvars` file:

```hcl
region = "us-east-1"

instance_type = "t3.large"

servers = {
  application1 = "Windows application server"
  application2 = "Windows test server"
}
```

Or provide a value on the command line:

```bash
terraform plan -var='region=us-east-1' -var='instance_type=t3.micro'
```

Changing the map keys changes the resource identities. Plan carefully before renaming or removing keys.

## Security Considerations

The intended RDP rule allows TCP port 3389 from `10.0.0.0/16`, which is appropriate only if that CIDR represents a trusted network. Do not expose RDP to `0.0.0.0/0`. Prefer a VPN, bastion host, or AWS Systems Manager Session Manager for administration.

The current security group is not attached to the EC2 instances. Attach it explicitly before using it as the instance access control. Also consider an IAM instance profile, encrypted EBS volumes, restricted egress, logging, and automatic patching.

The resource does not specify a subnet, key pair, or password retrieval workflow. Windows administration requires a planned access method and secure handling of credentials.

## Troubleshooting

### No default VPC is found

The `aws_vpc.default` data source requires a default VPC in the selected region. Create or restore a default VPC, or replace the data source with an explicitly managed VPC and subnet configuration.

### No Windows AMI matches the filter

AMI names and availability vary by region. Confirm that Amazon Windows Server 2025 images exist in the selected region and that the AWS identity can describe public Amazon images. Adjust the name filter if the regional AMI naming pattern differs.

### RDP access does not work

The RDP security group is not currently attached to the instances. Add `vpc_security_group_ids = [aws_security_group.rdp.id]`, then verify that the source IP is within `10.0.0.0/16`, the instance has network connectivity, and Windows is running and listening on port 3389.

### Terraform reports an invalid instance type

Verify that the selected type is available in the region and compatible with the Windows AMI architecture. Windows instances generally require more resources than lightweight Linux test instances, so confirm account quota and expected cost.

### `AccessDenied` or quota errors

Check permissions for EC2, AMI discovery, VPC discovery, and security-group management. Review regional EC2 quotas and any organization policies that restrict Windows workloads.

### The instance is created in an unexpected network

No subnet is specified in `aws_instance.windows`. AWS may use default VPC behavior. For predictable placement, define a subnet in the selected VPC and set `subnet_id` explicitly.

### The AMI output differs between runs

The data source uses `most_recent = true`. A newer matching Windows AMI may become available. Pin a reviewed AMI ID when repeatable deployments are more important than automatic image freshness.

### Terraform prompts for a variable

Provide values in a `.tfvars` file or on the command line:

```bash
terraform plan -var='instance_type=t3.micro'
```

### Changing server names causes replacements

The `for_each` keys are resource identity. Renaming `web1` to another key creates a new resource address and may destroy the old instance. Use `terraform state mv` when preserving an existing instance is required.

## Lessons Learned

- `for_each` makes it straightforward to create named Windows instances from a map.
- Data sources can select the latest regional AMI and discover the default VPC.
- AMI selection should account for region, image family, architecture, and operational stability.
- A security group must be explicitly associated with an EC2 instance to control its traffic.
- RDP should be restricted to trusted networks or replaced with a managed access service.
- Default VPC behavior is convenient for learning but should be replaced with explicit networking in production.

## Conclusion

Folder36 demonstrates how Terraform can combine data sources and `for_each` to create multiple Windows EC2 instances from a reusable configuration. It also highlights an important infrastructure principle: declaring a security group does not automatically attach it to a workload. Before using this example beyond a lab, attach the intended security group, define networking and access methods explicitly, secure RDP, and decide whether dynamic AMI selection or a pinned, tested image is the right operational choice.
