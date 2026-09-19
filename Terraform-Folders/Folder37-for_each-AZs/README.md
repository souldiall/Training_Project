# Folder37: EC2 Instances Across Supported Availability Zones

This Terraform example uses `for_each` to create one EC2 instance in every availability zone that supports the selected instance type. It dynamically discovers the latest Amazon Linux 2023 AMI and returns a map of availability zones to public IP addresses.

## What This Configuration Creates

For the configured AWS region and instance type, Terraform creates:

- One EC2 instance per supported availability zone
- Amazon Linux 2023 instances using an Amazon-owned AMI
- An Apache HTTP server on each instance through `user_data`
- An HTML page identifying the instance availability zone
- A `public_ips` output mapping each availability zone to its instance public IP

The defaults are:

- Region: `us-east-1`
- Instance type: `t3.micro`

## How Availability Zones Are Selected

The `aws_ec2_instance_type_offerings` data source queries availability zones where the selected instance type is offered:

```hcl
data "aws_ec2_instance_type_offerings" "supported" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}
```

The resource converts the returned locations to a set and uses that set as the `for_each` collection. Each key becomes the `availability_zone` and the instance `Name` tag.

The `aws_availability_zones.all` data source also lists opt-in-not-required zones, but it is not currently used to create instances. The actual resource count is controlled by the supported instance-type offerings data source.

## Files

- `data.tf`: Discovers available zones, the latest Amazon Linux 2023 AMI, and instance-type offerings.
- `main.tf`: Creates one EC2 instance per supported availability zone.
- `variables.tf`: Defines the AWS region and instance type.
- `provider.tf`: Configures AWS using the selected region.
- `output.tf`: Returns public IPs keyed by availability zone.
- `versions.tf`: Defines Terraform and AWS provider version constraints.

## Prerequisites

- Terraform approximately `1.15` according to `versions.tf`
- AWS provider version `6.x`
- AWS credentials configured for the account
- Permission to describe AMIs, availability zones, and instance offerings
- Permission to launch and manage EC2 instances
- A usable default VPC or networking configuration in the selected region
- An instance type available in at least one availability zone

The startup script uses `yum`, so the selected AMI must be compatible with RPM-based Amazon Linux distributions.

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Display the availability-zone-to-public-IP map:

```bash
terraform output public_ips
```

Test an instance after Apache starts:

```bash
curl http://<public-ip>
```

Remove the instances when finished:

```bash
terraform destroy
```

## Customizing Variables

Override the region or instance type in a `.tfvars` file:

```hcl
aws_region   = "us-east-1"
instance_type = "t3.micro"
```

Or pass a value at plan/apply time:

```bash
terraform plan -var='aws_region=us-east-1' -var='instance_type=t3.micro'
```

Changing `instance_type` can change the set of supported availability zones and therefore the `for_each` instances Terraform manages.

## Networking and Security Notes

The EC2 resource does not specify a subnet, security group, key pair, or explicit public-IP setting. AWS therefore relies on default VPC and subnet behavior for the selected availability zone. This is convenient for a learning example but is not predictable enough for production.

Before production use, define a VPC, subnet IDs, security groups, IAM instance profile, key or Session Manager access, encrypted volumes, and explicit public-IP behavior. If HTTP access is required, the security group must allow TCP port 80 from the intended source range.

## `for_each` Identity

The resource address is based on the availability-zone key:

```text
aws_instance.az_instances["us-east-1a"]
```

If the instance type changes and an availability zone is no longer supported, Terraform may destroy the instance for that key. If a new zone becomes supported, Terraform may create a new instance there.

## Troubleshooting

### No availability zones or instance offerings are returned

Check that the selected instance type is available in the configured region and that the AWS identity can describe instance offerings. Try a common type such as `t3.micro` and confirm the region spelling.

### `InvalidAMIID.NotFound`

The AMI filter is region-specific. Confirm that Amazon Linux 2023 kernel 6.1 x86_64 images exist in the selected region and that the account can describe public Amazon images.

### The instance fails during startup

The `user_data` script uses `yum` and installs `httpd`. A non-Amazon Linux image may use a different package manager or service name. Check the EC2 system log and cloud-init output.

### Apache cannot be reached

The configuration does not define a security group. Check the effective security group, subnet route, public-IP assignment, and internet gateway. Add an explicit security group allowing TCP port 80 from the intended source.

### Public IPs are empty

No explicit public-IP association is configured. Check whether the selected default subnet automatically assigns public IPv4 addresses. For predictable behavior, configure the subnet and public-IP association explicitly.

### Terraform creates a different number of instances

The count follows the availability zones that support `var.instance_type`, not a hard-coded number. Review the data source result and check regional offerings and account restrictions.

### An instance type is unavailable in one zone

This is expected when offerings differ by availability zone. The configuration creates instances only in zones returned by `aws_ec2_instance_type_offerings`.

### Terraform prompts for a variable

Provide a value in a `.tfvars` file or on the command line:

```bash
terraform plan -var='instance_type=t3.micro'
```

### Changes to instance type cause replacements

The instance type affects both the resource argument and the set of supported AZ keys. Review the plan carefully because changing it can replace instances or change the number of instances.

### Provider or version errors occur

Confirm that `versions.tf` is present, run `terraform init`, and verify that the selected AWS provider version satisfies the `~> 6.0` constraint.

## Lessons Learned

- `for_each` can use dynamically discovered availability zones rather than a hard-coded list.
- Instance-type offerings vary by region and availability zone, so discovery is safer than assuming uniform support.
- Data sources can drive both resource count and placement.
- `for_each` keys become stable resource identities, but changes to the discovered set can create or destroy instances.
- AMI filters should match the operating system, architecture, and region requirements.
- Explicit networking and security resources are important when moving beyond a learning environment.

## Conclusion

Folder37 demonstrates how Terraform can discover supported availability zones and create one EC2 instance in each using `for_each`. It combines data sources, dynamic placement, AMI selection, startup configuration, and map-based outputs in a compact example. Before using the pattern in production, define networking and security explicitly, review the impact of changing instance types, and validate the selected AMI and availability-zone offerings in each target region.
