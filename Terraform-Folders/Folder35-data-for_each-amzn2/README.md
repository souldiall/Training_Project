# Folder35: Amazon Linux 2 EC2 Instances with `for_each`

This Terraform example creates multiple EC2 instances from a map and dynamically selects the latest Amazon-owned Amazon Linux 2 AMI. It demonstrates how `for_each` and an AMI data source can produce repeatable instance resources without hard-coded AMI IDs.

## What This Configuration Creates

With the default values, Terraform creates three EC2 instances in `us-west-2`:

- `web1`
- `web2`
- `web3`

All instances use:

- The latest matching Amazon Linux 2 AMI
- Instance type `t3.micro`
- A `Name` tag equal to the map key

The configuration also outputs the AMI ID used by each instance.

## AMI Selection

The `aws_ami` data source selects the most recent Amazon-owned image matching:

```text
amzn2-ami-hvm-*-x86_64-gp2
```

This filter targets Amazon Linux 2 HVM x86_64 images using GP2 root volumes. The selected AMI is regional, so it is looked up in the provider region, `us-west-2`.

The data source is named `amazLiunx` in the Terraform code. The label is misspelled, but the reference is consistent and does not prevent Terraform from working.

## Files

- `data.tf`: Looks up the latest Amazon Linux 2 AMI.
- `main.tf`: Creates one EC2 instance for each key in `var.instances`.
- `variable.tf`: Defines the instance map.
- `provider.tf`: Configures AWS in `us-west-2`.
- `output.tf`: Returns the AMI ID used by each instance.
- `version.tf`: Defines Terraform and AWS provider version constraints.

## `for_each` Behavior

The resource uses:

```hcl
for_each = var.instances
```

The map keys become Terraform resource addresses and instance names:

```text
aws_instance.instances["web1"]
aws_instance.instances["web2"]
aws_instance.instances["web3"]
```

The current map values (`Hello`, `World`, and `Test`) are not used by `main.tf`; they are descriptive values only. Every instance uses the hard-coded `t3.micro` type.

## Prerequisites

- Terraform `>= 1.15`
- AWS provider `>= 6.50`
- AWS credentials configured for the account
- Permission to describe public AMIs and create and manage EC2 instances
- Sufficient EC2 quota in `us-west-2`
- A compatible default networking environment or an extended configuration with explicit subnet and security-group settings

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

Destroy the instances when finished:

```bash
terraform destroy
```

## Customizing the Instance Map

Override the map in a `.tfvars` file:

```hcl
instances = {
  application1 = "Application server"
  application2 = "Test server"
}
```

The values are currently descriptive only. If different instance types or settings are required per instance, change the variable structure and resource expressions so those values are used.

Renaming a map key changes the Terraform resource address and may cause Terraform to destroy the old instance and create a new one.

## Networking and Security Notes

The EC2 resource does not specify a subnet, security group, key pair, IAM role, user data, or explicit public-IP behavior. It relies on AWS and the account's default networking behavior. This is suitable for a simple learning example but should be made explicit for production.

Before using this configuration for real workloads, add a VPC or selected subnet, a least-privilege security group, an IAM instance profile, encrypted storage, controlled administrative access, and monitoring. Avoid exposing instances directly to the internet.

## Troubleshooting

### No AMI matches the filter

Confirm that Amazon Linux 2 AMIs matching `amzn2-ami-hvm-*-x86_64-gp2` are available in `us-west-2`. Verify that the AWS identity can describe public Amazon images and that the filter has not become outdated.

### The selected AMI is not suitable

Check the image architecture, virtualization type, root-device type, and operating-system family. The filter targets x86_64 HVM GP2 images, not ARM or newer Amazon Linux 2023 images.

### `AccessDenied` or EC2 quota errors

Verify permissions for AMI discovery and EC2 operations. Check regional EC2 service quotas and organization policies that may restrict instance creation.

### The instance is created in an unexpected network

No subnet or security group is specified. AWS may use default VPC behavior. Define `subnet_id` and `vpc_security_group_ids` explicitly when predictable placement and access control are required.

### Public IP or remote access does not work

No public-IP association or inbound security-group rule is configured in this folder. Check the selected subnet, route table, internet gateway, and security group. Add only the required inbound ports from trusted sources.

### Terraform output shows an unexpected AMI ID

The data source uses `most_recent = true`, so a newer matching AMI may be selected. Pin a reviewed AMI ID when repeatable deployments are more important than automatic image freshness.

### Terraform creates a different number of instances

The count is determined by the number of entries in `var.instances`. Review the map passed through a `.tfvars` file or command-line variable.

### Changing an instance name causes replacement

`for_each` uses map keys as resource identity. Use `terraform state mv` when renaming a key should preserve the existing instance rather than create a replacement.

### Terraform prompts for a variable

Provide the map in a `.tfvars` file or with `-var`:

```bash
terraform plan -var='instances={web1="Hello",web2="World"}'
```

### Provider or version errors occur

Run `terraform init` and confirm that `version.tf` exists and the installed AWS provider satisfies the `>= 6.50` constraint.

## Lessons Learned

- `for_each` is useful for creating named resources from a map.
- Data sources can find a current regional AMI without hard-coding an AMI ID.
- AMI filters should match the desired operating system, architecture, virtualization, and storage requirements.
- `for_each` keys become stable resource identities, so key changes should be planned carefully.
- Dynamic AMI selection improves freshness but can reduce reproducibility without an approval or pinning strategy.
- Production EC2 resources need explicit networking, security groups, IAM roles, storage settings, and access controls.

## Conclusion

Folder35 demonstrates a simple and reusable pattern for creating multiple Amazon Linux 2 EC2 instances with `for_each` and a filtered AMI data source. The configuration keeps resource names predictable and avoids hard-coded image IDs. Before using it in production, make network placement and security explicit, decide whether to pin or automatically update AMIs, and refactor the descriptive map values if they should control instance configuration.
