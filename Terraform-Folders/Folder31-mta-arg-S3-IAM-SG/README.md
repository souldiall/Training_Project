# Folder31: S3, IAM Users, and Security Group with Meta-Arguments

This example demonstrates how Terraform meta-arguments and expressions can manage several AWS resource types from variable collections. It creates S3 buckets, IAM users, and a security group whose ingress rules are generated from a list of ports.

## What This Configuration Creates

Using the default variable values, Terraform creates:

- Three S3 buckets for logs, images, and backups
- Three IAM users: `Mamadou`, `Oumar`, and `Boubacar`
- One security group allowing TCP traffic on ports `22`, `80`, and `443`
- One output containing the allowed ports as a comma-separated string

The AWS provider is configured for the `us-east-1` region.

## Terraform Patterns Demonstrated

### `for_each` for S3 buckets

The `buckets` map creates one `aws_s3_bucket` resource for each map entry. The map key identifies the resource instance, while the map value becomes the globally unique S3 bucket name.

### `count` for IAM users

The `iam_users` list creates one IAM user for each list item. Terraform uses `count.index` to select the name at the current list position.

### Dynamic blocks for security-group rules

The `allowed_ports` list is used by a dynamic `ingress` block. Each port produces a TCP ingress rule with `0.0.0.0/0` as its source.

### Explicit dependencies

The IAM users depend on the S3 buckets, and the security group depends on the IAM users. These dependencies are declared with `depends_on`, although the resources do not otherwise need each other to function.

## Files

- `main.tf`: Defines the S3 buckets, IAM users, and security group.
- `variables.tf`: Defines bucket names, IAM user names, and allowed ports.
- `provider.tf`: Configures AWS in `us-east-1`.
- `version.tf`: Defines Terraform and AWS provider version constraints.
- `output.tf`: Joins the allowed ports into a readable string.

## Prerequisites

- Terraform newer than `1.15`
- AWS provider version `6.5` or newer
- AWS credentials configured in the environment or through the AWS CLI
- IAM permissions to create and manage S3 buckets, IAM users, and security groups
- An AWS region with an available VPC for the security group

## Usage

Run these commands from this directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

To remove the resources created by this example:

```bash
terraform destroy
```

Review the output value with:

```bash
terraform output ports_string
```

## Customizing the Configuration

Values can be changed in a `.tfvars` file or on the command line. For example:

```hcl
buckets = {
  logs = "unique-project-logs-2026"
}

iam_users     = ["Alice", "Bob"]
allowed_ports = [80, 443]
```

The S3 bucket names must be globally unique across AWS. The values in the `buckets` map, rather than its keys, are used as the actual bucket names.

## Security Considerations

The security group allows TCP traffic from `0.0.0.0/0`, which means any IPv4 address can attempt to connect to ports `22`, `80`, and `443`. This is especially risky for SSH on port 22. Restrict `cidr_blocks` to trusted networks before using this configuration in a real environment.

The configuration creates IAM users but does not create passwords, access keys, groups, policies, or least-privilege permissions. Avoid creating long-lived IAM users for workloads; use IAM roles where possible and configure permissions intentionally.

The S3 buckets have no encryption, lifecycle rules, versioning, logging, or bucket policies defined in this example. Add those controls according to the data sensitivity and operational requirements.

## Troubleshooting

### `BucketAlreadyExists` or an unavailable bucket name

S3 bucket names are globally unique. Change the bucket values in `variables.tf` or provide unique values through a `.tfvars` file. Adding an account, project, or random suffix is a common approach.

### `AccessDenied` from AWS

Check that the active AWS identity has permission to create S3 buckets, IAM users, security groups, and related resources. Confirm the identity and region with the AWS CLI before applying.

### IAM user creation fails because the name already exists

IAM user names are unique within an AWS account. Choose different names or import the existing users into Terraform state if they are already managed resources.

### Security group creation fails because no VPC is available

The security group resource does not specify a `vpc_id`, so AWS uses the account's default VPC behavior. Verify that the selected region has a default VPC, or update the resource to use an explicitly selected VPC ID.

### Terraform reports an invalid port value

`allowed_ports` must be a list of numbers. Use values between `0` and `65535`, and avoid duplicate entries unless duplicate rules are intentional.

### Terraform prompts for a variable

Provide the variable in a `.tfvars` file or pass it explicitly. For example:

```bash
terraform plan -var='allowed_ports=[80,443]'
```

### Destroy is blocked or resources remain

Check the Terraform plan and state for resources created outside this configuration. The current lifecycle settings allow destruction, but AWS may still reject deletion when dependencies, non-empty buckets, or account policies prevent it.

### `terraform validate` fails after adding an environment or value

Run `terraform fmt` first, then inspect the variable types. `buckets` must be a map of strings, `iam_users` must be a list of strings, and `allowed_ports` must be a list of numbers.

## Lessons Learned

- `for_each` is a good fit for keyed resources such as environment or purpose-based buckets.
- `count` is convenient for simple positional lists, but changing list order can cause resource replacement or renaming behavior.
- Dynamic blocks reduce repeated configuration when rules are driven by a collection.
- Explicit `depends_on` controls ordering but should be used only when Terraform cannot infer a dependency naturally.
- AWS names and S3 bucket names have different uniqueness scopes and should be planned carefully.
- Network rules and IAM identities should follow least-privilege principles rather than broad defaults.

## Conclusion

Folder31 shows how Terraform can combine `for_each`, `count`, dynamic blocks, variables, locals, outputs, and explicit dependencies in one configuration. It is useful as a learning example for generating multiple AWS resources from collections. Before using it in a production environment, restrict security-group sources, add IAM permissions deliberately, use roles where appropriate, and add S3 security and data-management controls.
