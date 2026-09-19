# Folder38: Amazon Linux 2023 AMI Filtering

This Terraform example creates multiple EC2 instances by selecting the latest Amazon-owned Amazon Linux 2023 AMI dynamically. It uses `for_each` with a map so each instance receives a stable Terraform address and a tag based on its map key.

## What This Configuration Creates

With the default values, Terraform creates three EC2 instances in `us-east-1`:

- `server1`
- `server2`
- `server3`

All instances use the shared `t3.micro` instance type and the AMI returned by `data.aws_ami.al2023`.

## AMI Selection

The data source selects the most recent AMI that matches all of these filters:

- Name: `al2023-ami-*-x86_64`
- Architecture: `x86_64`
- Virtualization: `hvm`
- Root device: `ebs`
- State: `available`
- Owner: Amazon (`amazon`)

This avoids hard-coding an AMI ID, but it also means a future plan may select a newer image when the filter result changes.

## Files

- `data.tf`: Finds the most recent matching Amazon Linux 2023 AMI.
- `main.tf`: Creates one EC2 instance for each key in `var.aws_instance`.
- `variables.tf`: Defines the shared instance type and instance map.
- `output.tf`: Returns a map of instance keys to public IP addresses.
- `provider.tf`: Configures AWS in `us-east-1`.
- `version.tf`: Defines Terraform and AWS provider version constraints.

## `for_each` Behavior

The `aws_instance` resource uses:

```hcl
for_each = var.aws_instance
```

The map keys become instance addresses and the `Name` tag values:

```text
aws_instance.server["server1"]
aws_instance.server["server2"]
aws_instance.server["server3"]
```

The current map values are descriptive strings, but they are not used by `main.tf`. The `instance_type` variable controls the type for every instance.

## Lifecycle Behavior

The resource uses `create_before_destroy = true`, allowing Terraform to create a replacement before removing the old instance when replacement is required.

It also uses:

```hcl
ignore_changes = [ami, instance_type, tags]
```

Changes to those attributes will not appear as managed updates in the plan. This can prevent automatic AMI updates and tag corrections, so remove an ignored attribute when Terraform should manage it again.

## Prerequisites

- Terraform approximately `1.15` according to `version.tf`
- AWS provider version `6.x`
- AWS credentials configured for the account
- Permission to describe AMIs and create, tag, and manage EC2 instances
- An AWS account and region with sufficient EC2 quota

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Display the public IP map:

```bash
terraform output public_ip
```

Remove the instances when finished:

```bash
terraform destroy
```

## Customizing Variables

Change the common instance type or instance map in a `.tfvars` file:

```hcl
instance_type = "t3.small"

aws_instance = {
  web1 = "web-instance"
  web2 = "web-instance"
}
```

The map values are currently descriptive only. If different instance types are required per instance, change the variable structure and resource expression so the values are used.

## Security and Operations Notes

This configuration does not define a security group, key pair, subnet, IAM role, encrypted EBS settings, or user data. The instances therefore depend on the account's default networking behavior and do not include application bootstrap configuration.

Selecting the latest AMI improves freshness but should be tested before production rollout. Consider pinning a reviewed AMI ID or adding an approval workflow for image changes.

## Troubleshooting

### No AMI matches the filters

Confirm that Amazon Linux 2023 x86_64 AMIs are available in `us-east-1`, that the AWS provider can describe public images, and that the AMI name pattern is still correct. Check the active account and region.

### The selected AMI is not compatible

The filters select x86_64 HVM EBS-backed images, but verify that the image is compatible with the chosen instance type and startup requirements. Adjust the filters if a different architecture or image family is needed.

### Terraform does not update to a newer AMI

The lifecycle rule ignores changes to `ami`. Remove `ami` from `ignore_changes` if Terraform should replace instances when the selected AMI changes.

### Terraform does not correct the instance type or tags

`instance_type` and `tags` are also ignored by the lifecycle configuration. Remove those attributes from `ignore_changes` to let Terraform manage future changes.

### An instance type is unavailable

Check that the type is supported in `us-east-1`, that it matches the AMI architecture, and that the account has enough service quota. Try a supported alternative such as `t3.micro`.

### `AccessDenied` or EC2 quota errors

Verify permissions for AMI discovery and EC2 operations. Check regional vCPU and instance quotas and confirm that organizational policies do not block launches.

### Public IP output is empty

No public IP is explicitly requested in the resource. Check the selected subnet's public-IP behavior and account networking defaults. For predictable networking, define a subnet and public IP association explicitly.

### Terraform prompts for a variable

Provide values in a `.tfvars` file or on the command line:

```bash
terraform plan -var='instance_type=t3.micro'
```

### Changing map keys causes unexpected replacements

`for_each` uses map keys as stable resource identity. Renaming a key creates a new instance address and can destroy the old instance. Use `terraform state mv` when a rename should preserve an existing resource.

## Lessons Learned

- Data sources can select an AMI dynamically instead of relying on a hard-coded image ID.
- Multiple AMI filters make image selection more precise and reduce accidental matches.
- `for_each` with map keys provides stable, readable instance addresses.
- Lifecycle `ignore_changes` is powerful but can hide updates that operators expect Terraform to apply.
- Resource identity is tied to `for_each` keys, so key changes should be planned carefully.
- Production EC2 configurations need explicit networking, security groups, IAM roles, storage, and access controls.

## Conclusion

Folder38 demonstrates a reusable pattern for launching several EC2 instances from the latest Amazon Linux 2023 AMI. The combination of filtered AMI discovery and `for_each` keeps the configuration concise and makes instance naming predictable. Before using this pattern in production, review the lifecycle ignore rules, validate new AMIs, define explicit networking and security controls, and decide whether automatic image updates are appropriate.
